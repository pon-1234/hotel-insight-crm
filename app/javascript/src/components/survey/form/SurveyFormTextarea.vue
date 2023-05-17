<template>
  <div>
    <survey-question-header :question="question" :qnum="qnum"></survey-question-header>
    <ValidationProvider name="答え" :rules="{ required: isRequired, max: 2000 }" v-slot="{ errors }">
      <textarea
        rows="3"
        :name="`answers[${qnum}][answer]`"
        class="form-control mt-2"
        placeholder="入力してください"
        v-validate="'required|max:255'"
        v-model.trim="answer"
        data-vv-as="答え"
      />
      <error-message :message="errors[0]"></error-message>
    </ValidationProvider>
  </div>
</template>

<script>
export default {
  props: ['question', 'qnum', 'answers'],

  created() {
    if (this.answers && this.answers[this.qnum]) {
      this.answer = this.answers[this.qnum].answer;
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
    }
  }
};
</script>

<style lang="scss" scoped>
</style>
