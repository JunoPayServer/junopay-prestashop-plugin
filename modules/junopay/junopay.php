<?php

if (!defined('_PS_VERSION_')) {
    exit;
}

class JunoPay extends PaymentModule
{
    public function __construct()
    {
        $this->name = 'junopay';
        $this->tab = 'payments_gateways';
        $this->version = '0.1.0';
        $this->author = 'Juno Pay Server';
        $this->controllers = array('validation', 'invoice');
        $this->currencies = true;
        $this->currencies_mode = 'checkbox';
        $this->bootstrap = true;
        parent::__construct();
        $this->displayName = $this->l('JunoPay');
        $this->description = $this->l('Accept JUNO payments through Juno Pay Server.');
    }

    public function install()
    {
        return parent::install()
            && $this->registerHook('paymentOptions')
            && $this->registerHook('paymentReturn')
            && $this->ensureInvoiceSchema();
    }

    public function ensureInvoiceSchema()
    {
        $db = Db::getInstance();
        if (!$db->execute('CREATE TABLE IF NOT EXISTS `' . _DB_PREFIX_ . 'junopay_invoice` (
            `id_order` INT UNSIGNED NOT NULL,
            `invoice_id` VARCHAR(128) NOT NULL,
            `invoice_token` VARCHAR(255) NOT NULL DEFAULT "",
            `address` TEXT NOT NULL,
            `amount_zat` BIGINT UNSIGNED NOT NULL,
            `received_zat_pending` BIGINT UNSIGNED NOT NULL DEFAULT 0,
            `received_zat_confirmed` BIGINT UNSIGNED NOT NULL DEFAULT 0,
            `status` VARCHAR(64) NOT NULL DEFAULT "",
            `expires_at` VARCHAR(64) NOT NULL DEFAULT "",
            PRIMARY KEY (`id_order`)
        ) ENGINE=' . _MYSQL_ENGINE_ . ' DEFAULT CHARSET=utf8mb4')) {
            return false;
        }

        $columns = array();
        foreach ($db->executeS('SHOW COLUMNS FROM `' . _DB_PREFIX_ . 'junopay_invoice`') as $row) {
            $columns[$row['Field']] = true;
        }

        $alters = array(
            'invoice_token' => 'ADD `invoice_token` VARCHAR(255) NOT NULL DEFAULT "" AFTER `invoice_id`',
            'received_zat_pending' => 'ADD `received_zat_pending` BIGINT UNSIGNED NOT NULL DEFAULT 0 AFTER `amount_zat`',
            'received_zat_confirmed' => 'ADD `received_zat_confirmed` BIGINT UNSIGNED NOT NULL DEFAULT 0 AFTER `received_zat_pending`',
            'status' => 'ADD `status` VARCHAR(64) NOT NULL DEFAULT "" AFTER `received_zat_confirmed`',
            'expires_at' => 'ADD `expires_at` VARCHAR(64) NOT NULL DEFAULT "" AFTER `status`',
        );

        foreach ($alters as $column => $sql) {
            if (!isset($columns[$column]) && !$db->execute('ALTER TABLE `' . _DB_PREFIX_ . 'junopay_invoice` ' . $sql)) {
                return false;
            }
        }

        return true;
    }

    public function hookPaymentOptions($params)
    {
        if (!$this->active) {
            return array();
        }
        $option = new PrestaShop\PrestaShop\Core\Payment\PaymentOption();
        $option->setCallToActionText($this->l('Pay with JunoPay'));
        if (method_exists($option, 'setModuleName')) {
            $option->setModuleName($this->name);
        }
        $option->setAction($this->context->link->getModuleLink($this->name, 'validation', array(), true))
            ->setAdditionalInformation($this->l('A JUNO deposit address is generated after you place the order.'));
        return array($option);
    }

    public function createInvoice(Cart $cart)
    {
        $baseUrl = rtrim((string)Configuration::get('JUNOPAY_BASE_URL'), '/');
        $apiKey = (string)Configuration::get('JUNOPAY_MERCHANT_API_KEY');
        if ($baseUrl === '' || $apiKey === '') {
            throw new Exception('JunoPay is not configured.');
        }

        $rate = (float)(Configuration::get('JUNOPAY_ZATOSHIS_PER_CURRENCY_UNIT') ?: 100000000);
        $amountZat = (int)round((float)$cart->getOrderTotal(true, Cart::BOTH) * $rate);
        $payload = json_encode(array(
            'external_order_id' => 'prestashop-cart-' . (int)$cart->id,
            'amount_zat' => $amountZat,
            'metadata' => array(
                'platform' => 'prestashop',
                'cart_id' => (string)$cart->id,
            ),
        ));

        $ch = curl_init($baseUrl . '/v1/invoices');
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json', 'Authorization: Bearer ' . $apiKey));
        curl_setopt($ch, CURLOPT_POSTFIELDS, $payload);
        curl_setopt($ch, CURLOPT_TIMEOUT, 20);
        $body = curl_exec($ch);
        $status = (int)curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
        $err = curl_error($ch);
        curl_close($ch);
        if ($body === false || $status < 200 || $status > 299) {
            throw new Exception($err ?: 'JunoPay invoice creation failed.');
        }
        $decoded = json_decode($body, true);
        $data = isset($decoded['data']) && is_array($decoded['data']) ? $decoded['data'] : array();
        $invoice = isset($data['invoice']) ? $data['invoice'] : array();
        $invoiceToken = isset($data['invoice_token']) ? (string)$data['invoice_token'] : '';
        $address = isset($invoice['address']) ? $invoice['address'] : (isset($invoice['payment_address']) ? $invoice['payment_address'] : '');
        if (empty($invoice['invoice_id']) || $address === '' || $invoiceToken === '') {
            throw new Exception('JunoPay returned an incomplete invoice.');
        }
        $invoice['invoice_token'] = $invoiceToken;
        return array($invoice, $address, $amountZat);
    }

    public function getPublicInvoice($invoiceId, $invoiceToken)
    {
        $baseUrl = rtrim((string)Configuration::get('JUNOPAY_BASE_URL'), '/');
        if ($baseUrl === '') {
            throw new Exception('JunoPay is not configured.');
        }

        $ch = curl_init($baseUrl . '/v1/public/invoices/' . rawurlencode((string)$invoiceId) . '?token=' . rawurlencode((string)$invoiceToken));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_TIMEOUT, 15);
        $body = curl_exec($ch);
        $status = (int)curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
        $err = curl_error($ch);
        curl_close($ch);
        if ($body === false || $status < 200 || $status > 299) {
            throw new Exception($err ?: 'JunoPay status refresh failed.');
        }

        $decoded = json_decode($body, true);
        if (!is_array($decoded) || ($decoded['status'] ?? '') !== 'ok' || !isset($decoded['data'])) {
            throw new Exception('JunoPay returned an invalid status response.');
        }

        return $decoded['data'];
    }

    public function invoicePhase(array $invoice)
    {
        $amount = isset($invoice['amount_zat']) ? (int)$invoice['amount_zat'] : 0;
        $pending = isset($invoice['received_zat_pending']) ? (int)$invoice['received_zat_pending'] : 0;
        $confirmed = isset($invoice['received_zat_confirmed']) ? (int)$invoice['received_zat_confirmed'] : 0;
        $expiresAt = isset($invoice['expires_at']) ? (string)$invoice['expires_at'] : '';

        if ($expiresAt !== '') {
            $expiry = strtotime($expiresAt);
            if ($expiry !== false && $expiry <= time() && ($pending + $confirmed) < $amount) {
                return 'expired';
            }
        }

        if ($amount > 0 && $confirmed >= $amount) {
            return 'confirmed';
        }

        if ($amount > 0 && ($pending + $confirmed) >= $amount) {
            return 'paid';
        }

        if (($pending + $confirmed) > 0) {
            return 'underpaid';
        }

        return 'awaiting_payment';
    }
}
