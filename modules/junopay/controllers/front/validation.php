<?php

class JunoPayValidationModuleFrontController extends ModuleFrontController
{
    public function postProcess()
    {
        $cart = $this->context->cart;
        if (!$cart || !$cart->id_customer || !$cart->id_address_delivery || !$cart->id_address_invoice) {
            Tools::redirect('index.php?controller=order');
        }

        try {
            list($invoice, $address, $amountZat) = $this->module->createInvoice($cart);
            $this->module->ensureInvoiceSchema();
            $customer = new Customer((int)$cart->id_customer);
            $this->module->validateOrder((int)$cart->id, (int)Configuration::get('PS_OS_BANKWIRE'), (float)$cart->getOrderTotal(true, Cart::BOTH), $this->module->displayName, 'JunoPay invoice: ' . $invoice['invoice_id'] . "\nAddress: " . $address, array(), null, false, $customer->secure_key);
            $orderId = (int)$this->module->currentOrder;
            $phase = $this->module->invoicePhase($invoice);
            Db::getInstance()->insert('junopay_invoice', array(
                'id_order' => $orderId,
                'invoice_id' => pSQL($invoice['invoice_id']),
                'invoice_token' => pSQL($invoice['invoice_token']),
                'address' => pSQL($address),
                'amount_zat' => (int)$amountZat,
                'received_zat_pending' => isset($invoice['received_zat_pending']) ? (int)$invoice['received_zat_pending'] : 0,
                'received_zat_confirmed' => isset($invoice['received_zat_confirmed']) ? (int)$invoice['received_zat_confirmed'] : 0,
                'status' => pSQL($phase),
                'expires_at' => isset($invoice['expires_at']) ? pSQL($invoice['expires_at']) : '',
            ), false, true, Db::REPLACE);
            Tools::redirect($this->context->link->getModuleLink($this->module->name, 'invoice', array(
                'id_order' => $orderId,
                'key' => $customer->secure_key,
            ), true));
        } catch (Exception $e) {
            $this->errors[] = $e->getMessage();
            $this->redirectWithNotifications('index.php?controller=order');
        }
    }
}
