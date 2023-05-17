<template>
  <div>
    <survey-question-header :question="question" :qnum="qnum"></survey-question-header>
    <div class="mt-2">
      <div
        class="custom-control custom-checkbox custom-control-inline d-flex flex-start"
        v-for="(option, index) in options"
        :key="index"
      >
        <input
          type="checkbox"
          class="custom-control-input"
          v-model="selectedOptions"
          :id="`${prefix}Option${index}`"
          :value="option.value"
        />
        <label class="custom-control-label" :for="`${prefix}Option${index}`">{{ option.value }}</label>
      </div>

      <ValidationProvider name="答え" :rules="{ required: isRequired }" v-slot="{ errors }">
        <input type="hidden" v-model="answer" :name="`answers[${qnum}][answer]`" />
        <error-message :message="errors[0]"></error-message>
      </ValidationProvider>
    </div>
  </div>
</template>

<script>
export default {
  props: ['question', 'qnum', 'answers'],

  data() {
    return {
      selectedOptions: [],
      answer: null
    };
  },

  created() {
    if (this.answers && this.answers[this.qnum]) {
      this.answer = this.answers[this.qnum].answer;
      this.selectedOptions = this.answers[this.qnum].answer.split(',');
    }
  },

  watch: {
    selectedOptions: {
      handler(val) {
        this.answer = val.join(',');
      }
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
    },

    options() {
      return this.content ? this.content.options : [];
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
</style>
