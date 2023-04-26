<template>
  <ValidationObserver ref="observer">
    <form
      ref="form"
      @submit.prevent="onSubmit"
      :action="formAction"
      method="post"
      enctype="multipart/form-data"
    >
      <input type="hidden" name="authenticity_token" :value="csrfToken" />
      <div class="card" v-if="survey">
        <div v-show="step1">
          <div class="card-body">
            <ValidationObserver ref="innerObs">
              <main-default-form @update-required="updateRequired" :dateRequired="dateRequired" :haveApiKey="haveApiKey" :answers="answers" :survey="surveyStep1"></main-default-form>
            </ValidationObserver>
          </div>
          <div class="card-footer text-align-center border-top-0">
            <button type="button" class="btn btn-success fw-120" @click="nextStep()">送信</button>
          </div>
        </div>
        <div v-show="step2" >
          <div class="card-body">
          <survey-form-content :answers="answers" :startIndex= "STEP1_QUESTION_NUM" :survey="surveyStep2"></survey-form-content>
          </div>
          <div class="card-footer text-align-center border-top-0">
            <button type="submit" class="btn btn-success fw-120" :startIndex="7">送信</button>
          </div>
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
import { mapActions, mapMutations, mapState } from 'vuex';
import Util from '@/core/util.js';
import moment from 'moment-timezone';

export default {
  props: {
    code: {
      type: Number
    },
    friend_id: {
      type: String
    },
    answers: {
      type: Array
    },
    haveApiKey: {
      type: Boolean
    }
  },

  data() {
    return {
      userRootUrl: process.env.MIX_ROOT_PATH,
      csrfToken: Util.getCsrfToken(),
      loading: true,
      survey: null,
      STEP1_QUESTION_NUM: 6,
      step1: true,
      step2: false,
      dateRequired: false
    };
  },

  async beforeMount() {
    this.survey = await this.getSurveyByCode(this.code);
    const questionsStep1 = this.survey.questions.slice(0, this.STEP1_QUESTION_NUM);
    const questionsStep2 = this.survey.questions.slice(this.STEP1_QUESTION_NUM);
    this.surveyStep1 = Object.assign({}, this.survey, { questions: questionsStep1 });
    this.surveyStep2 = Object.assign({}, this.survey, { questions: questionsStep2 });
    this.loading = false;
  },

  created() {
    if (!this.answers[7].answer) {
      this.answers[7].answer = this.defaultStartBirthdate;
    }
  },

  computed: {
    ...mapState('survey', {
      datetimeQuestion: state => state.datetimeQuestion
    }),

    formAction() {
      return `${this.userRootUrl}/surveys/precheckin_answer/${this.code}/${this.friend_id}`;
    },

    defaultStartBirthdate() {
      return moment()
        .subtract(20, 'years')
        .tz('Asia/Tokyo')
        .format();
    }
  },

  methods: {
    ...mapMutations('survey', ['setDatetimeRequired']),
    ...mapActions('survey', ['getSurveyByCode', 'postAnswer']),

    async onSubmit() {
      await Object.entries(this.datetimeQuestion).forEach(([qnum, ques]) => {
        if (ques.required) {
          this.setDatetimeRequired({ ques_num: qnum, status: true });
        }
      });
      const isValid = await this.$refs.observer.validate();
      if (isValid) {
        this.$refs.form.submit();
      }
    },

    async nextStep() {
      await this.updateRequired(true);
      this.$refs.innerObs.validate().then(success => {
        if (success) {
          this.step1 = false;
          this.step2 = true;
        }
      });
    },
    updateRequired(val) {
      this.dateRequired = val;
    }
  }
};
</script>

<style scoped>

</style>
