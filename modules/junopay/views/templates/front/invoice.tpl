{literal}
<style>
.junopay-page {
  min-height: 70vh;
  padding: 32px 16px;
  background: #f6f2ec;
}
.junopay-card {
  max-width: 780px;
  margin: 0 auto;
  overflow: hidden;
  border: 1px solid #ded7cd;
  border-radius: 18px;
  background: #fff;
  box-shadow: 0 20px 60px rgba(35, 25, 16, 0.14);
}
.junopay-card__header {
  padding: 30px;
  background: #191715;
  color: #fff;
}
.junopay-card__brand {
  display: flex;
  align-items: center;
  gap: 13px;
}
.junopay-card__mark {
  width: 48px;
  height: 48px;
  flex: 0 0 48px;
}
.junopay-card h1 {
  margin: 0;
  color: #fff;
  font-family: inherit;
  font-size: 28px;
  line-height: 1.2;
  font-weight: 800;
}
.junopay-card__status {
  display: inline-block;
  margin-top: 16px;
  padding: 6px 10px;
  border-radius: 999px;
  background: rgba(245, 154, 61, 0.16);
  color: #ffd5a7;
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: .06em;
}
.junopay-card__body {
  padding: 30px;
}
.junopay-card__lead {
  margin: 0 0 22px;
  color: #5f574f;
  font-size: 16px;
  line-height: 1.55;
}
.junopay-card__grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 14px;
}
.junopay-card__pay {
  display: grid;
  grid-template-columns: 240px 1fr;
  gap: 18px;
  align-items: start;
}
.junopay-qr {
  min-height: 240px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid #e6e0d8;
  border-radius: 14px;
  background: #fff;
  padding: 12px;
}
.junopay-qr canvas {
  max-width: 100%;
  height: auto;
}
.junopay-field {
  border: 1px solid #e6e0d8;
  border-radius: 14px;
  padding: 16px;
  background: #fbfaf8;
}
.junopay-field__label {
  margin: 0 0 8px;
  color: #847a70;
  font-size: 12px;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: .05em;
}
.junopay-field__row {
  display: flex;
  align-items: center;
  gap: 10px;
}
.junopay-field__value {
  min-width: 0;
  flex: 1;
  margin: 0;
  color: #211d18;
  font-family: Menlo, Monaco, Consolas, "Courier New", monospace;
  font-size: 15px;
  line-height: 1.55;
  word-break: break-all;
}
.junopay-field__amount {
  font-family: inherit;
  font-size: 32px;
  line-height: 1.1;
  font-weight: 800;
  letter-spacing: 0;
}
.junopay-copy {
  border: 1px solid #d8843f;
  border-radius: 9px;
  background: #fff;
  color: #a45c1f;
  font-weight: 700;
  padding: 9px 12px;
  cursor: pointer;
}
.junopay-card__hint {
  margin: 18px 0 0;
  color: #6b6259;
  line-height: 1.55;
}
@media (max-width: 640px) {
  .junopay-page { padding: 12px; }
  .junopay-card { border-radius: 14px; }
  .junopay-card__header, .junopay-card__body { padding: 22px; }
  .junopay-card__pay { grid-template-columns: 1fr; }
  .junopay-field__row { align-items: stretch; flex-direction: column; }
  .junopay-copy { width: 100%; }
}
</style>
{/literal}
<section class="junopay-page">
  <div class="junopay-card junopay-checkout" data-address="{if $invoice}{$invoice.address|escape:'html':'UTF-8'}{/if}" data-status-url="{$status_url|escape:'html':'UTF-8'}">
    <div class="junopay-card__header">
      <div class="junopay-card__brand">
        <svg class="junopay-card__mark" viewBox="0 0 64 64" fill="none" aria-hidden="true" focusable="false">
          <circle cx="32" cy="32" r="32" fill="#FD930D"/>
          <path d="M25.9016 49.3247V49.3511H25.969C25.9413 49.3436 25.9214 49.3323 25.9016 49.3247ZM18.7482 42.4228V44.7071H20.9965V42.4228H18.7482ZM16.3373 40.0179V42.3022H18.5935V40.0179H16.3373ZM18.7839 35.9431V38.2274H21.175V35.9431H18.7839ZM14.6996 35.9959V37.4773H16.25V35.9959H14.6996ZM12.5107 39.2904V40.1838H13.4585V39.2904H12.5107ZM12.598 42.7357V43.4708H13.3712V42.7357H12.598ZM17.0709 43.9419V44.5224H17.6815V43.9419H17.0709ZM14.4656 44.6506V46.0491H15.9288V44.6506H14.4656ZM17.0153 46.95V48.2014H18.3318V46.95H17.0153ZM19.7554 48.5972V49.3511H20.5484V48.5972H19.7554ZM22.5708 49.6376V50.1993H23.1616V49.6376H22.5708ZM25.7668 49.7846V50.7232H26.7542V49.7846H25.7668ZM28.2927 50.4217V51.4884H29.4149V50.4217H28.2927ZM20.9926 44.7034V47.1535H23.4035V44.7034H20.9926ZM23.4035 47.1535V49.6037H25.4853V47.1535H23.4035ZM32.0518 14.9547L32.0796 23.1948L37.405 23.2136L37.4328 38.7966C37.4407 41.5747 35.4184 43.5838 32.5713 43.8779C29.4427 44.1983 26.5757 42.2306 26.314 39.1924C26.2268 38.1596 26.3537 37.2059 26.199 36.1806H22.4716V39.935H20.9886V42.4191H23.3995V44.7034H25.5289V47.1535H27.6979V49.7205H28.2887V50.154C29.3554 50.4028 30.4657 50.5423 31.6117 50.5423C32.4642 50.5423 33.2969 50.4971 34.1098 50.3953C35.803 50.1917 37.4209 49.7432 38.9594 48.8686C42.7344 46.7238 45.1374 42.9129 45.1453 38.6307L45.2325 14.917L32.0439 14.9547H32.0518ZM25.739 41.8423H24.0062V40.1838H25.739V41.8423ZM28.1222 46.3431H26.4845V44.7976H28.1222V46.3431ZM30.541 49.6112H28.4117V47.587H30.541V49.6112ZM25.969 49.3549H25.9016V49.3285C25.9016 49.3285 25.9413 49.3474 25.969 49.3549Z" fill="white"/>
          <path d="M34.3602 38.5564L29.4931 38.5838L30.9363 32.8679C29.7424 32.3173 29.1425 31.154 29.4184 29.912C29.6641 28.8001 30.6785 27.9533 31.8857 27.933C33.0928 27.9127 34.1241 28.7212 34.4108 29.8176C34.7325 31.0477 34.1807 32.2349 32.9904 32.832L34.3602 38.5552V38.5564Z" fill="white"/>
        </svg>
        <h1>Pay with JunoPay</h1>
      </div>
      <span class="junopay-card__status junopay-status">Awaiting payment</span>
    </div>
    <div class="junopay-card__body">
      {if $invoice}
        <p class="junopay-card__lead">Send the exact amount below from your JUNO wallet. The order will update after payment is detected.</p>
        <div class="junopay-card__pay">
          <div class="junopay-qr" aria-label="Payment QR code"></div>
          <div class="junopay-card__grid">
            <div class="junopay-field">
              <p class="junopay-field__label">Amount</p>
              <p class="junopay-field__value junopay-field__amount">{$amount|escape:'html':'UTF-8'}</p>
            </div>
            <div class="junopay-field">
              <p class="junopay-field__label">Deposit address</p>
              <div class="junopay-field__row">
                <p class="junopay-field__value" data-junopay-copy-value>{$invoice.address|escape:'html':'UTF-8'}</p>
                <button class="junopay-copy" type="button" data-junopay-copy>Copy</button>
              </div>
            </div>
            <div class="junopay-field">
              <p class="junopay-field__label">Invoice</p>
              <p class="junopay-field__value">{$invoice.invoice_id|escape:'html':'UTF-8'}</p>
            </div>
          </div>
        </div>
        <p class="junopay-card__hint">Keep this page open while your wallet sends the transaction.</p>
      {else}
        <p class="junopay-card__lead">Invoice details are unavailable. Return to checkout and place the order again.</p>
      {/if}
    </div>
  </div>
</section>
{literal}
<script>
(function() {
  var button = document.querySelector('[data-junopay-copy]');
  var value = document.querySelector('[data-junopay-copy-value]');
  if (!button || !value) return;
  button.addEventListener('click', function() {
    var text = value.textContent.replace(/^\s+|\s+$/g, '');
    var done = function() {
      button.textContent = 'Copied';
      setTimeout(function() { button.textContent = 'Copy'; }, 1600);
    };
    if (navigator.clipboard && navigator.clipboard.writeText) {
      navigator.clipboard.writeText(text).then(done);
    } else {
      var input = document.createElement('textarea');
      input.value = text;
      document.body.appendChild(input);
      input.select();
      document.execCommand('copy');
      document.body.removeChild(input);
      done();
    }
  });
})();
</script>
{/literal}
<script src="{$checkout_js|escape:'html':'UTF-8'}"></script>
