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
