<template>
  <div>
    <survey-question-header :question="question" :qnum="qnum"></survey-question-header>
    <div class="form-group mt-2">
      <div class="input-group">
        <div class="custom-file">
          <input
            type="file"
            class="custom-file-input"
            id="inputFile"
            :name="`answers[${qnum}][answer]`"
            @change="onFileChange"
          />
          <label class="custom-file-label" for="inputFile">{{ fileName || "ファイルを選択" }}</label>
        </div>
      </div>
      <error-message message="ファイルの形式が無効です。" v-if="!this.isValidMineType"></error-message>
      <ValidationProvider name="答え" :rules="{ required: isRequired }" v-slot="{ errors }">
        <input type="hidden" v-model="fileName" />
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
      fileName: null,
      isValidMineType: true
    };
  },

  created() {
    if (this.answers && this.answers[this.qnum]) {
      this.fileName = this.answers[this.qnum].answer;
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
    onFileChange(event) {
      var fileData = event.target.files[0];
      this.fileName = null;
      this.isValidMineType = false;
      if (fileData && fileData.type === 'application/pdf') {
        this.isValidMineType = true;
        this.fileName = fileData.name;
      }
    }
  }
};
</script>
