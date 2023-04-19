<template>
  <div>
    <survey-question-header :question="question" :qnum="qnum"></survey-question-header>
    <ValidationProvider name="答え" :rules="{ required: isRequired }" v-slot="{ errors }">
      <div class="form-group mt-2 position-relative">
        <datetime
          input-class="form-control btn border border-light text-left"
          type="date"
          :phrases="{ ok: '確定', cancel: '閉じる' }"
          placeholder="日付を選択してください"
          value-zone="Asia/Tokyo"
          zone="Asia/Tokyo"
          :name="`answers[${qnum}][answer]`"
          v-model="answer"
        ></datetime>
        <i class="dripicons-chevron-down dropdown-icon"></i>
      </div>
      <!-- the below check is to fix bug datetime component auto validate on show -->
      <error-message :message="errors[0]"></error-message>
    </ValidationProvider>
  </div>
</template>

<script>
import { Datetime } from 'vue-datetime';
import { mapGetters, mapMutations, mapState } from 'vuex';

export default {
  components: {
    Datetime
  },

  props: ['question', 'qnum'],

  data() {
    return {
      answer: null
    };
  },

  created() {
    this.setDatetimeQuestion({ ques_num: this.qnum, ques: this.question });
  },

  computed: {
    ...mapGetters('survey', ['getDatetimeRequired']),
    ...mapState('survey', {
      datetimeRequired: state => state.datetimeRequired,
      datetimeQuestion: state => state.datetimeQuestion
    }),

    prefix() {
      return `surveyQuestion${this.qnum}`;
    },

    isRequired() {
      return this.getDatetimeRequired(this.qnum);
    },

    content() {
      return this.question ? this.question.content : '';
    },

    title() {
      return this.content ? this.content.text : '';
    },

    subTitle() {
      return this.content ? this.content.sub_text : '';
    }
  },

  methods: {
    ...mapMutations('survey', ['setDatetimeQuestion', 'setDatetimeRequired']),

    onOptionChanged() {
      return 0;
    }
  },

  watch: {
    answer(newAnswer) {
      if (newAnswer && this.datetimeQuestion[this.qnum].required) {
        this.setDatetimeRequired({ ques_num: this.qnum, status: true });
      }
    }
  }
};
</script>

<style lang="scss" scoped>
  .dropdown-icon {
    position: absolute;
    top: calc(50% - 10px);
    right: 5px;
  }
</style>
