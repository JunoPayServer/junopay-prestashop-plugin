<?php

class JunoPayInvoiceModuleFrontController extends ModuleFrontController
{
    public function postProcess()
    {
        if ((int)Tools::getValue('ajax') === 1 && Tools::getValue('action') === 'status') {
            $this->renderStatus();
        }
    }

    public function initContent()
    {
        parent::initContent();
        $orderId = (int)Tools::getValue('id_order');
        $order = new Order($orderId);
        $orderKey = Validate::isLoadedObject($order) ? $order->secure_key : '';
        $this->module->ensureInvoiceSchema();
        $invoice = Db::getInstance()->getRow('SELECT * FROM ' . _DB_PREFIX_ . 'junopay_invoice WHERE id_order = ' . $orderId);
        $statusUrl = $this->context->link->getModuleLink($this->module->name, 'invoice', array(
            'ajax' => 1,
            'action' => 'status',
            'id_order' => $orderId,
            'key' => $orderKey,
        ), true);
        $this->context->smarty->assign(array(
            'invoice' => $invoice,
            'amount' => isset($invoice['amount_zat']) ? ((int)$invoice['amount_zat'] / 100000000) . ' JUNO' : '',
            'status_url' => $statusUrl,
            'checkout_js' => $this->module->getPathUri() . 'views/js/checkout.js',
        ));
        $this->setTemplate('module:junopay/views/templates/front/invoice.tpl');
    }

    private function renderStatus()
    {
        $orderId = (int)Tools::getValue('id_order');
        $order = new Order($orderId);
        if (!Validate::isLoadedObject($order) || Tools::getValue('key') !== $order->secure_key) {
            $this->json(array('ok' => false, 'error' => 'invalid_order'));
        }

        $this->module->ensureInvoiceSchema();
        $stored = Db::getInstance()->getRow('SELECT * FROM ' . _DB_PREFIX_ . 'junopay_invoice WHERE id_order = ' . $orderId);
        if (!$stored || empty($stored['invoice_id']) || empty($stored['invoice_token'])) {
            $this->json(array('ok' => false, 'error' => 'missing_invoice'));
        }

        try {
            $data = $this->module->getPublicInvoice($stored['invoice_id'], $stored['invoice_token']);
            $invoice = isset($data['invoice']) && is_array($data['invoice']) ? $data['invoice'] : $data;
            $phase = $this->module->invoicePhase($invoice);
            $previousPhase = isset($stored['status']) ? (string)$stored['status'] : '';

            Db::getInstance()->update('junopay_invoice', array(
                'received_zat_pending' => isset($invoice['received_zat_pending']) ? (int)$invoice['received_zat_pending'] : 0,
                'received_zat_confirmed' => isset($invoice['received_zat_confirmed']) ? (int)$invoice['received_zat_confirmed'] : 0,
                'status' => pSQL($phase),
                'expires_at' => isset($invoice['expires_at']) ? pSQL($invoice['expires_at']) : '',
            ), 'id_order = ' . $orderId);

            if ($previousPhase !== $phase) {
                $orderState = null;
                if ($phase === 'confirmed') {
                    $orderState = (int)Configuration::get('PS_OS_PAYMENT');
                } elseif ($phase === 'expired') {
                    $orderState = (int)Configuration::get('PS_OS_CANCELED');
                }

                if ($orderState && (int)$order->current_state !== $orderState) {
                    $history = new OrderHistory();
                    $history->id_order = $orderId;
                    $history->changeIdOrderState($orderState, $orderId);
                    $history->addWithemail(true, array());
                }
            }

            $this->json(array(
                'ok' => true,
                'phase' => $phase,
                'order_status' => $phase,
                'invoice' => $invoice,
            ));
        } catch (Exception $e) {
            $this->json(array('ok' => false, 'error' => $e->getMessage()));
        }
    }

    private function json(array $payload)
    {
        header('Content-Type: application/json');
        die(json_encode($payload));
    }
}
