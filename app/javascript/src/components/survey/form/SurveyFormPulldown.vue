<template>
  <div>
    <survey-question-header :question="question" :qnum="qnum"></survey-question-header>
    <ValidationProvider name="答え" :rules="{ required: isRequired }" v-slot="{ errors }">
      <select class="form-control w-100" :name="`answers[${qnum}][answer]`" v-model="answer">
        <option v-for="(option, index) in options" :key="index" :value="option.value">
          {{ option.value }}
        </option>
      </select>
      <error-message :message="errors[0]"></error-message>
    </ValidationProvider>
  </div>
</template>

<script>
export default {
  props: ['question', 'qnum', 'answers'],

  data() {
    return {
      answer: null
    };
  },

  created() {
    if (this.answers && this.answers[this.qnum]) {
      this.answer = this.answers[this.qnum].answer;
    } else {
      this.answer = this.options && this.options.length > 0 ? this.options[0].value : null;
    }
  },

  computed: {
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
  }
};
</script>

<style lang="scss" scoped>
</style>
