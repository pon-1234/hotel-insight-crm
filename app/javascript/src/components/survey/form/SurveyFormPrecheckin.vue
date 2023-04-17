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
      <div class="card" v-if="survey">
        <div class="card-body">
          <div class="bg-white" v-if="survey">
            <img :src="`${survey.banner_url}`" v-if="survey.banner_url" class="banner mb-1">
            <div class="font-weight-bold">{{ survey.title }}</div>
            <div class="font-12">{{ survey.description }}</div>

            <div class="mt-2">
              <div>
                <survey-question-header :question="survey.questions[1]" :qnum="1"></survey-question-header>
                <ValidationProvider name="電話番号" rules="required|numeric|min:10|max:11" v-slot="{ errors }">
                  <input
                  rows="3"
                  type="number"
                  class="form-control mt-2"
                  :name="`answers[${1}][answer]`"
                  placeholder="電話番号を入力してください"
                  v-model.trim="answers[1]"
                  />
                  <error-message :message="errors[0]"></error-message>
                </ValidationProvider>
              </div>
              <div>
                <survey-question-header :question="survey.questions[2]" :qnum="2"></survey-question-header>
                <ValidationProvider name="チェックイン日" rules="required" v-slot="{ errors }">
                  <div class="form-group mt-2 position-relative">
                    <datetime
                      input-class="form-control btn border border-light text-left"
                      type="date"
                      :phrases="{ ok: '確定', cancel: '閉じる' }"
                      placeholder="チェックイン日を選択してください"
                      value-zone="Asia/Tokyo"
                      zone="Asia/Tokyo"
                      :name="`answers[${2}][answer]`"
                      v-model="answers[2]"
                    ></datetime>
                    <i class="dripicons-chevron-down dropdown-icon"></i>
                  </div>
                  <error-message :message="errors[0]"></error-message>
                </ValidationProvider>
              </div>
            </div>
          </div>
        </div>
        <div class="card-footer text-align-center pb-3 border-top-0">
          <button type="submit" class="btn btn-precheckin fw-120">予約照合</button>
        </div>
        <loading-indicator :loading="loading"></loading-indicator>
      </div>
      <div class="alert alert-warning" role="alert" v-if="!survey && !loading">
        <h4 class="alert-heading">エラー</h4>
        <p>アクセスが拒否されました。</p>
      </div>
    </form>
  </ValidationObserver>
</template>

<script>
import { mapActions } from 'vuex';
import Util from '@/core/util.js';
import moment from 'moment-timezone';
import { Datetime } from 'vue-datetime';

export default {
  props: {
    code: {
      type: Number
    },
    friend_id: {
      type: String
    }
  },

  components: {
    Datetime
  },

  data() {
    return {
      userRootUrl: process.env.MIX_ROOT_PATH,
      csrfToken: Util.getCsrfToken(),
      loading: true,
      survey: null,
      answers: []
    };
  },

  async beforeMount() {
    this.survey = await this.getSurveyByCode(this.code);
    this.loading = false;
  },

  mounted() {
    this.answers[2] = this.defaultStartDate;
  },

  computed: {
    formAction() {
      return `${this.userRootUrl}/surveys/precheckin/${this.code}/${this.friend_id}`;
    },

    defaultStartDate() {
      return moment()
        .add(1, 'days')
        .tz('Asia/Tokyo')
        .format();
    }
  },

  methods: {
    ...mapActions('survey', ['getSurveyByCode', 'postAnswer']),

    async onSubmit(e) {
      this.$refs.form.submit();
    }
  }
};
</script>

<style scoped>
  .dropdown-icon {
    position: absolute;
    top: calc(50% - 10px);
    right: 5px;
  }
  .banner {
    width: 100%;
    height: auto;
    object-fit: contain;
  }
</style>
