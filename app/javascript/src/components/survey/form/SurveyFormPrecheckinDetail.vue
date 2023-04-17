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
        <div v-show="step1">
          <div class="card-body">
            <ValidationObserver ref="innerObs">
              <precheckin-default-form :answers="answers" :survey="surveyStep1"></precheckin-default-form>
            </ValidationObserver>
          </div>
          <div class="card-footer text-align-center border-top-0">
            <button type="button" class="btn btn-precheckin fw-120" @click="nextStep()">送信</button>
          </div>
        </div>
        <div v-show="step2" >
          <div class="card-body">
          <survey-form-content :answers="answers" :startIndex= "STEP1_QUESTION_NUM" :survey="surveyStep2"></survey-form-content>
          </div>
          <div class="card-footer text-align-center border-top-0">
            <button type="submit" class="btn btn-precheckin fw-120" :startIndex="7">送信</button>
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
import { mapActions } from 'vuex';
import Util from '@/core/util.js';

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
      step2: false
    };
  },

  async beforeMount() {
    this.survey = await this.getSurveyByCode(this.code);
    const questionsStep1 = this.survey.questions.slice(0, this.STEP1_QUESTION_NUM);
    const questionsStep2 = this.survey.questions.slice(this.STEP1_QUESTION_NUM);
    this.surveyStep1 = Object.assign({}, this.survey, { questions: questionsStep1 });
    console.log(this.surveyStep1);
    this.surveyStep2 = Object.assign({}, this.survey, { questions: questionsStep2 });
    this.loading = false;
  },

  computed: {
    formAction() {
      return `${this.userRootUrl}/surveys/${this.code}/${this.friend_id}`;
    }
  },

  methods: {
    ...mapActions('survey', ['getSurveyByCode', 'postAnswer']),

    async onSubmit(e) {
      this.$refs.form.submit();
    },
    nextStep() {
      this.$refs.innerObs.validate().then(success => {
        if (success) {
          this.step1 = false;
          this.step2 = true;
        }
      });
    }
  }
};
</script>

<style scoped>

</style>
