<template>
  <div>
    <div class="card">
      <div class="card-header d-flex align-items-center">
        <a :href="`${userRootUrl}/user/setting`" class="text-info">
          <i class="mdi mdi-arrow-left"></i>アカウント詳細
        </a>
        <h5 class="m-auto font-weight-bold">設定変更</h5>
      </div>
      <ValidationObserver ref="observer" v-slot="{ validate }">
        <form
          ref="form"
          @submit.prevent="validate().then(onSubmit)"
          :action="getAction()"
          method="post"
          enctype="multipart/form-data"
        >
          <input type="hidden" name="authenticity_token" :value="csrfToken" />
          <input type="hidden" name="_method" value="patch" />
          <input type="hidden" name="setting[id]" :value="settingFormData.id" />
          <div class="card-body">
            <div class="form-group d-flex">
              <label class="fw-350">LINE公式アカウントID<required-mark /></label>
              <div class="flex-grow-1">
                <ValidationProvider name="LINE公式アカウントID" rules="required|max:255" v-slot="{ errors }">
                  <input
                    type="text"
                    class="form-control"
                    name="setting[line_user_id]"
                    placeholder="入力してください"
                    maxlength="256"
                    v-model.trim="settingFormData.line_user_id"
                  />
                  <span class="error-explanation">{{ errors[0] }}</span>
                </ValidationProvider>
              </div>
            </div>
            <div class="form-group d-flex">
              <label class="fw-350">LIFF ID</label>
              <div class="flex-grow-1">
                <ValidationProvider name="LIFF ID" rules="max:255" v-slot="{ errors }">
                  <input
                    type="text"
                    class="form-control"
                    name="setting[liff_id]"
                    placeholder="入力してください"
                    maxlength="256"
                    v-model.trim="settingFormData.liff_id"
                  />
                  <span class="error-explanation">{{ errors[0] }}</span>
                </ValidationProvider>
              </div>
            </div>
            <div class="form-group d-flex">
              <label class="fw-350">PMS APIキー</label>
              <div class="flex-grow-1">
                <ValidationProvider name="PMS APIキー" rules="max:255" v-slot="{ errors }">
                  <input
                    type="text"
                    class="form-control"
                    name="setting[pms_api_key]"
                    placeholder="入力してください"
                    maxlength="256"
                    v-model.trim="settingFormData.pms_api_key"
                  />
                  <span class="error-explanation">{{ errors[0] }}</span>
                </ValidationProvider>
              </div>
            </div>
            <div class="form-group d-flex">
              <label class="fw-350">LINEアカウント名<required-mark /></label>
              <div class="flex-grow-1">
                <ValidationProvider name="LINEアカウント名" rules="required|max:255" v-slot="{ errors }">
                  <input
                    type="text"
                    class="form-control"
                    name="setting[line_name]"
                    placeholder="入力してください"
                    maxlength="256"
                    v-model.trim="settingFormData.line_name"
                  />
                  <span class="error-explanation">{{ errors[0] }}</span>
                </ValidationProvider>
              </div>
            </div>
            <div class="form-group d-flex">
              <label class="fw-350">表示名<required-mark /></label>
              <div class="flex-grow-1">
                <ValidationProvider name="表示名" rules="required|max:255" v-slot="{ errors }">
                  <input
                    type="text"
                    class="form-control"
                    name="setting[display_name]"
                    placeholder="入力してください"
                    maxlength="256"
                    v-model.trim="settingFormData.display_name"
                  />
                  <span class="error-explanation">{{ errors[0] }}</span>
                </ValidationProvider>
              </div>
            </div>
            <div class="form-group d-flex">
              <label class="fw-350">チャネルID</label>
              <div class="flex-grow-1">
                <input
                  type="text"
                  class="form-control"
                  placeholder="入力してください"
                  v-model.trim="settingFormData.channel_id"
                  maxlength="256"
                  disabled
                />
              </div>
            </div>
            <div class="form-group d-flex">
              <label class="fw-350">チャネルシークレット</label>
              <div class="flex-grow-1">
                <input
                  type="text"
                  class="form-control"
                  placeholder="入力してください"
                  v-model.trim="settingFormData.channel_secret"
                  maxlength="256"
                  disabled
                />
              </div>
            </div>
            <div class="form-group d-flex">
              <label class="fw-350">Webhook URL</label>
              <div class="flex-grow-1">
                <input type="text" class="form-control" placeholder="入力してください" :value="webhookUrl()" disabled />
              </div>
            </div>
          </div>
          <div class="card-footer row-form-btn d-flex">
            <submit-button object="設定" action="保存" :submitted="submitted"></submit-button>
          </div>
        </form>
      </ValidationObserver>
      <loading-indicator :loading="loading" />
    </div>
  </div>
</template>

<script>
import Util from '@/core/util.js';
import { ValidationObserver, ValidationProvider } from 'vee-validate';

export default {
  props: ['line_account'],
  components: { ValidationObserver, ValidationProvider },
  data() {
    return {
      userRootUrl: process.env.MIX_ROOT_PATH,
      csrfToken: Util.getCsrfToken(),
      loading: false,
      submitted: false,
      settingFormData: {
        id: null,
        line_user_id: null,
        line_name: null,
        display_name: null,
        channel_id: null,
        channel_secret: null,
        liff_id: null,
        pms_api_key: null
      }
    };
  },

  created() {
    Object.assign(this.settingFormData, this.line_account);
  },

  methods: {
    async onSubmit(e) {
      this.submitted = true;
      this.$refs.form.submit();
    },
    getAction() {
      return `${this.userRootUrl}/user/setting`;
    },
    webhookUrl() {
      return `${this.userRootUrl}/webhooks/${this.line_account.webhook_url}`;
    }
  }
};
</script>

<style lang="scss" scoped>
</style>
