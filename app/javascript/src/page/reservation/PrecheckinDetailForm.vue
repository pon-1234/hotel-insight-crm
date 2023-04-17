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
          <div v-show="firstStep">
            <ValidationObserver ref="innerObs">
              <!-- お名前 -->
              <div>
                <p class="w-100 mb-1">
                  <span class="border-success question-title mr-2 font-weight-bold">Q1</span
                  >お名前 <required-mark></required-mark>
                </p>
                <div class="col-lg-8">
                  <ValidationProvider name="お名前" rules="required|max:255" v-slot="{ errors }">
                    <input
                      type="text"
                      class="form-control"
                      name="precheckin[name]"
                      placeholder="お名前を入力してください"
                      v-model.trim="precheckinFormData.name"
                    />
                    <span class="error-explanation">{{ errors[0] }}</span>
                  </ValidationProvider>
                </div>
              </div>

              <!-- 電話番号 -->
              <div>
                <p class="w-100 mb-1">
                  <span class="border-success question-title mr-2 font-weight-bold">Q2</span
                  >電話番号 / Phone Number <required-mark></required-mark>
                </p>
                <div class="w-100 text-muted text-sm my-1">ご予約に使った電話番号をご入力してください</div>
                <div class="col-lg-8">
                  <ValidationProvider name="電話番号" rules="required|numeric|min:10|max:11" v-slot="{ errors }">
                    <input
                      type="number"
                      class="form-control"
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
                  <span class="border-success question-title mr-2 font-weight-bold">Q3</span
                  >チェックイン日 / Check-In Date <required-mark></required-mark>
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
                      format="yyyy-MM-dd"
                    ></datetime>
                    <error-message :message="errors[0]"></error-message>
                  </ValidationProvider>
                </div>
              </div>

              <!-- チェックアウト日 -->
              <div>
                <p class="w-100 mb-1">
                  <span class="border-success question-title mr-2 font-weight-bold">Q4</span
                  >チェックアウト日 / Check-Out Date <required-mark></required-mark>
                </p>
                <div class="w-100 text-muted text-sm my-1">ご予約のチェックアウト日をご入力してください</div>
                <div class="col-lg-8">
                  <ValidationProvider name="チェックアウト日" rules="required" v-slot="{ errors }">
                    <datetime
                      input-class="form-control"
                      type="date"
                      :phrases="{ ok: '確定', cancel: '閉じる' }"
                      placeholder="チェックアウト日を選択してください"
                      name="precheckin[check_out_date]"
                      value-zone="Asia/Tokyo"
                      zone="Asia/Tokyo"
                      v-model="precheckinFormData.check_out_date"
                      format="yyyy-MM-dd"
                    ></datetime>
                    <error-message :message="errors[0]"></error-message>
                  </ValidationProvider>
                </div>
              </div>

              <!-- 住所 -->
              <div>
                <p class="w-100 mb-1">
                  <span class="border-success question-title mr-2 font-weight-bold">Q5</span
                  >住所 / Address <required-mark></required-mark>
                </p>
                <div class="col-lg-8">
                  <ValidationProvider name="住所" rules="required|max:255" v-slot="{ errors }">
                    <input
                      type="text"
                      class="form-control"
                      name="precheckin[address]"
                      placeholder="住所を入力してください"
                      maxlength="256"
                      v-model.trim="precheckinFormData.address"
                    />
                    <span class="error-explanation">{{ errors[0] }}</span>
                  </ValidationProvider>
                </div>
              </div>

              <!-- 性別 -->
              <div>
                <p class="w-100 mb-1">
                  <span class="border-success question-title mr-2 font-weight-bold">Q6</span
                  >性別 / Gender <required-mark></required-mark>
                </p>
                <div class="col-lg-8">
                  <ValidationProvider name="性別" rules="required" v-slot="{ errors }">
                    <select v-model="precheckinFormData.gender" name="precheckin[gender]" class="form-control">
                      <option v-for="(gender, index) in genders" :key="index" :value="index">
                        {{ gender }}
                      </option>
                    </select>
                    <span class="error-explanation">{{ errors[0] }}</span>
                  </ValidationProvider>
                </div>
              </div>
            </ValidationObserver>
          </div>
          <div v-show="!firstStep">
            <!-- 生年月日 -->
            <div>
              <p class="w-100 mb-1">
                <span class="border-success question-title mr-2 font-weight-bold">Q7</span
                >生年月日 / Birthdate <required-mark></required-mark>
              </p>
              <div class="col-lg-8">
                <ValidationProvider name="生年月日" rules="required" v-slot="{ errors }">
                  <datetime
                      input-class="form-control"
                      type="date"
                      :phrases="{ ok: '確定', cancel: '閉じる' }"
                      placeholder="チェックイン日を選択してください"
                      name="precheckin[birthdate]"
                      value-zone="Asia/Tokyo"
                      zone="Asia/Tokyo"
                      v-model="precheckinFormData.birthdate"
                      format="yyyy-MM-dd"
                  ></datetime>
                  <error-message :message="errors[0]"></error-message>
                </ValidationProvider>
              </div>
            </div>

            <!-- ご利用シーン -->
            <div>
              <p class="w-100 mb-1">
                <span class="border-success question-title mr-2 font-weight-bold">Q7</span
                >ご利用シーン / Use Scene <required-mark></required-mark>
              </p>
              <div class="col-lg-8">
                <ValidationProvider name="ご利用シーン" rules="required" v-slot="{ errors }">
                  <select v-model="precheckinFormData.companion" name="precheckin[companion]" class="form-control">
                    <option v-for="(companion, key) in companionOptions" :key="key" :value="key">
                      {{ companion }}
                    </option>
                  </select>
                  <span class="error-explanation">{{ errors[0] }}</span>
                </ValidationProvider>
              </div>
            </div>
          </div>
        </div>
        <div v-show="firstStep">
          <div class="card-footer border-top pb-3 border-top-0">
            <button type="button" class="btn btn-precheckin fw-120" @click="nextStep()">送信</button>
          </div>
        </div>
        <div v-show="!firstStep">
          <div class="card-footer border-top pb-3 border-top-0">
            <button type="submit" class="btn btn-precheckin fw-120">送信</button>
          </div>
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
  props: ['friendLineId', 'precheckinData'],
  components: {
    Datetime
  },

  data() {
    return {
      rootPath: process.env.MIX_ROOT_PATH,
      csrfToken: Util.getCsrfToken(),
      loading: true,
      firstStep: true,
      genders: ['男性', '女性', 'その他', '回答しない'],
      companionOptions: {
        single: '一人',
        couple: '恋人',
        friends: '友達',
        family: '家族',
        business: 'ビジネス',
        other: 'その他'
      },
      precheckinFormData: {
        name: null,
        phone_number: null,
        check_in_date: null,
        check_out_date: null,
        address: null,
        birthdate: null,
        companion: null,
        gender: null
      }
    };
  },

  async beforeMount() {
    this.loading = false;
  },

  created() {
    Object.assign(this.precheckinFormData, this.precheckinData);
    if (!Object.keys(this.companionOptions).includes(this.precheckinFormData.companion)) {
      this.precheckinFormData.companion = null;
    }
  },

  mounted() {
    this.precheckinFormData.birthdate = this.defaultStartBirthdate;
  },

  computed: {
    formAction() {
      return `${this.rootPath}/reservations/precheckin_detail/${this.friendLineId}`;
    },

    defaultStartBirthdate() {
      return moment()
        .subtract(20, 'years')
        .tz('Asia/Tokyo')
        .format();
    }
  },

  methods: {
    async onSubmit(e) {
      this.$refs.form.submit();
    },
    nextStep() {
      this.$refs.innerObs.validate().then(success => {
        if (success) {
          this.firstStep = !this.firstStep;
        }
      });
    }
  }
};
</script>
<style lang="scss" scoped>
  .back-button {
    margin-right: 100px;
  }
  .question-title {
    border-bottom: 3px solid #0acf97;
  }

  .text-sm {
    font-size: 0.7rem;
  }
</style>
