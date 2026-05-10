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
  border-radius: 50%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  background: #f59a3d;
  color: #fff;
  font-weight: 800;
  font-size: 25px;
  line-height: 1;
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
  .junopay-field__row { align-items: stretch; flex-direction: column; }
  .junopay-copy { width: 100%; }
}
</style>
{/literal}
<section class="junopay-page">
  <div class="junopay-card">
    <div class="junopay-card__header">
      <div class="junopay-card__brand">
        <div class="junopay-card__mark">J</div>
        <h1>Pay with JunoPay</h1>
      </div>
      <span class="junopay-card__status">Awaiting payment</span>
    </div>
    <div class="junopay-card__body">
      {if $invoice}
        <p class="junopay-card__lead">Send the exact amount below from your JUNO wallet. The order will update after payment is detected.</p>
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
