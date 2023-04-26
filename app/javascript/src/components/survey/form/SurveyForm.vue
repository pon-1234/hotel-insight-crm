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
        <div class="card-body">
          <survey-form-content :survey="survey" :preview="false"></survey-form-content>
        </div>
        <div class="card-footer border-top border-success text-align-center">
          <button type="submit" class="btn btn-success fw-120">送信</button>
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

export default {
  props: {
    code: {
      type: Number
    },
    friend_id: {
      type: String
    }
  },

  data() {
    return {
      userRootUrl: process.env.MIX_ROOT_PATH,
      csrfToken: Util.getCsrfToken(),
      loading: true,
      survey: null
    };
  },

  async beforeMount() {
    this.survey = await this.getSurveyByCode(this.code);
    this.loading = false;
  },

  computed: {
    ...mapState('survey', {
      datetimeQuestion: state => state.datetimeQuestion
    }),

    formAction() {
      return `${this.userRootUrl}/surveys/${this.code}/${this.friend_id}`;
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
    }
  }
};
</script>

<style>
</style>
