<template>
  <div>
    <survey-question-header :question="question" :qnum="qnum"></survey-question-header>
    <ValidationProvider name="答え" :rules="{ required: isRequired }" v-slot="{ errors }">
      <div class="form-group mt-2 position-relative">
        <datetime
          input-class="form-control btn border border-light text-left"
          type="datetime"
          :phrases="{ ok: '確定', cancel: '閉じる' }"
          placeholder="日付・時刻を選択してください"
          value-zone="Asia/Tokyo"
          zone="Asia/Tokyo"
          :name="`answers[${qnum}][answer]`"
          v-model="answer"
        ></datetime>
        <i class="dripicons-chevron-down dropdown-icon"></i>
      </div>
      <error-message :message="errors[0]"></error-message>
    </ValidationProvider>
  </div>
</template>

<script>
import { Datetime } from 'vue-datetime';
import moment from 'moment-timezone';

export default {
  components: {
    Datetime
  },

  props: ['question', 'qnum', 'answers'],

  data() {
    return {
      answer: null
    };
  },

  created() {
    if (this.answers && this.answers[this.qnum]) {
      this.answer = moment.tz(this.answers[this.qnum].answer, 'YYYY年M月D日 H:mm', 'Asia/Tokyo').format();
    }
  },

  computed: {
    prefix() {
      return `surveyQuestion${this.qnum}`;
    },

    isRequired() {
      return this.question ? this.question.required : false;
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
    onOptionChanged() {
      return 0;
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
