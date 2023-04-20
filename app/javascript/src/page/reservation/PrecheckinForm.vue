<template>
  <ValidationObserver ref="observer" v-slot="{ validate }">
    <form
      ref="form"
      @submit.prevent="validate().then(onSubmit)"
      :action="formAction"
      method="post"
      enctype="multipart/form-data"
    >
      <input type="hidden" name="authenticity_token" :value="csrfToken" />
      <input type="hidden" name="precheckin[friend_line_id]" :value="friendLineId" />
      <div class="card">
        <div class="card-header border-bottom border-success"><h4>事前チェックインフォーム</h4></div>
        <div class="card-body">
          <!-- 電話番号 -->
          <div>
            <p class="w-100 mb-1">
              <span class="border-success question-title mr-2 font-weight-bold">Q1</span
              >電話番号 <required-mark></required-mark>
            </p>
            <div class="w-100 text-muted text-sm my-1">ご予約に使った電話番号をご入力してください</div>
            <div class="col-lg-8">
              <ValidationProvider name="電話番号" rules="required|numeric|min:10|max:11" v-slot="{ errors }">
                <input
                  type="number"
                  class="form-control mt-2"
                  name="precheckin[phone_number]"
                  placeholder="電話番号を入力してください"
                  v-model.trim="precheckinFormData.phone_number"
                />
                <span class="error-explanation">{{ errors[0] }}</span>
              </ValidationProvider>
            </div>
          </div>

          <!-- チェックイン日 -->
          <div>
            <p class="w-100 mb-1">
              <span class="border-success question-title mr-2 font-weight-bold">Q2</span
              >チェックイン日 <required-mark></required-mark>
            </p>
            <div class="w-100 text-muted text-sm my-1">ご予約のチェックイン日をご入力してください</div>
            <div class="col-lg-8">
              <ValidationProvider name="チェックイン日" rules="required" v-slot="{ errors }">
                <datetime
                  input-class="form-control"
                  type="date"
                  :phrases="{ ok: '確定', cancel: '閉じる' }"
                  placeholder="チェックイン日を選択してください"
                  name="precheckin[check_in_date]"
                  value-zone="Asia/Tokyo"
                  zone="Asia/Tokyo"
                  v-model="precheckinFormData.check_in_date"
                ></datetime>
                <error-message :message="errors[0]"></error-message>
              </ValidationProvider>
            </div>
          </div>
        </div>
        <div class="card-footer border-top pb-3 border-top-0">
          <button type="submit" class="btn btn-sucess fw-120">予約照合</button>
        </div>
        <loading-indicator :loading="loading"></loading-indicator>
      </div>
    </form>
  </ValidationObserver>
</template>

<script>
import Util from '@/core/util.js';
import moment from 'moment-timezone';
import { Datetime } from 'vue-datetime';

export default {
  props: {
    friendLineId: {
      type: String
    }
  },

  components: {
    Datetime
  },

  data() {
    return {
      rootPath: process.env.MIX_ROOT_PATH,
      csrfToken: Util.getCsrfToken(),
      loading: true,
      precheckinFormData: {
        phone_number: null,
        check_in_date: null
      }
    };
  },

  async beforeMount() {
    this.loading = false;
  },

  mounted() {
    this.precheckinFormData.check_in_date = this.defaultStartDate;
  },

  computed: {
    formAction() {
      return `${this.rootPath}/reservations/precheckin/${this.friendLineId}`;
    },

    defaultStartDate() {
      return moment()
        .add(1, 'days')
        .tz('Asia/Tokyo')
        .format();
    }
  },

  methods: {
    async onSubmit(e) {
      this.$refs.form.submit();
    }
  }
};
</script>
<style lang="scss" scoped>
  .question-title {
    border-bottom: 3px solid #0acf97;
  }

  .text-sm {
    font-size: 0.7rem;
  }
</style>
