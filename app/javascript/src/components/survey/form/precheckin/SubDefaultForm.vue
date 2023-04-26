<template>
  <div class="bg-white" v-if="questions">
    <div class="mt-2">
      <div>
        <survey-question-header :question="questions[0]" :qnum="7"></survey-question-header>
        <ValidationProvider name="生年月日" rules="required" v-slot="{ errors }">
          <div class="form-group mt-2 position-relative">
            <datetime
              input-class="form-control btn border border-light text-left"
              type="date"
              :phrases="{ ok: '確定', cancel: '閉じる' }"
              placeholder="生年月日を選択してください"
              value-zone="Asia/Tokyo"
              zone="Asia/Tokyo"
              :name="`answers[${7}][answer]`"
              v-model="answers[7].answer"
            ></datetime>
            <i class="dripicons-chevron-down dropdown-icon"></i>
          </div>
          <error-message :message="errors[0]"></error-message>
        </ValidationProvider>
      </div>
      <div>
        <survey-question-header :question="questions[1]" :qnum="8"></survey-question-header>
        <ValidationProvider name="答え" :rules="{ required: isRequired }" v-slot="{ errors }">
          <select class="form-control w-100" :name="`answers[${8}][answer]`" v-model="answers[8].answer">
            <option v-for="(option, index) in questions[1].content.options" :key="index" :value="companionOptions[index]">
              {{ option.value }}
            </option>
          </select>
          <error-message :message="errors[0]"></error-message>
        </ValidationProvider>
      </div>
    </div>
  </div>
</template>

<script>
import { Datetime } from 'vue-datetime';

export default {
  props: {
    questions: {
      type: Object
    },
    answers: {
      type: Object
    }
  },

  components: {
    Datetime
  },

  data() {
    return {
      companionOptions: ['single', 'couple', 'friends', 'family', 'business', 'other']
    };
  },

  computed: {

  },

  created() {
    // debugger;
  }
};
</script>

<style scoped>
  .banner {
    width: 100%;
    height: auto;
    object-fit: contain;
  }
  .dropdown-icon {
    position: absolute;
    top: calc(50% - 10px);
    right: 5px;
  }
  .precheckin-alert {
    background-color: #FFECB5;
    padding: 10px;
    color: #000000;
    width: 60%;
  }
</style>
