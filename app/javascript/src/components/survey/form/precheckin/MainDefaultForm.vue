<template>
  <div class="bg-white" v-if="survey">
    <img :src="`${survey.banner_url}`" v-if="survey.banner_url" class="banner mb-1">
    <div class="font-weight-bold">{{ survey.title }}</div>
    <div class="font-12">{{ survey.description }}</div>
    <div v-if="!verifyReservation && haveApiKey" class="font-10 mt-2 precheckin-alert">
      予約を照合できませんでした、予約データのご入力をお願いいたします。
    </div>
    <div class="mt-2">
      <div>
        <survey-question-header :question="survey.questions[0]" :qnum="1"></survey-question-header>
        <ValidationProvider name="答え" :rules="{ required: true, max: 255 }" v-slot="{ errors }">
          <input
            type="text"
            :name="`answers[${1}][answer]`"
            class="form-control mt-2"
            placeholder="入力してください"
            v-model.trim="answers[1].answer"
            :readonly="verifyReservation"
          />
          <error-message :message="errors[0]"></error-message>
        </ValidationProvider>
      </div>
      <div>
        <survey-question-header :question="survey.questions[1]" :qnum="2"></survey-question-header>
        <ValidationProvider name="電話番号" rules="required|numeric|min:10|max:11" v-slot="{ errors }">
          <input
          rows="3"
          type="number"
          class="form-control mt-2"
          :name="`answers[${2}][answer]`"
          placeholder="電話番号を入力してください"
          v-model.trim="answers[2].answer"
          :readonly="verifyReservation"
          />
          <error-message :message="errors[0]"></error-message>
        </ValidationProvider>
      </div>
      <div>
        <survey-question-header :question="survey.questions[2]" :qnum="3"></survey-question-header>
        <ValidationProvider name="チェックイン日" :rules="{ required: dateRequired }" v-slot="{ errors }">
          <div class="form-group mt-2 position-relative">
            <datetime
              input-class="form-control btn border border-light text-left"
              type="date"
              :phrases="{ ok: '確定', cancel: '閉じる' }"
              placeholder="チェックイン日を選択してください"
              value-zone="Asia/Tokyo"
              zone="Asia/Tokyo"
              :name="`answers[${3}][answer]`"
              v-model="answers[3].answer"
              :readonly="verifyReservation"
            ></datetime>
            <i class="dripicons-chevron-down dropdown-icon"></i>
          </div>
          <error-message :message="errors[0]"></error-message>
        </ValidationProvider>
      </div>
      <div>
        <survey-question-header :question="survey.questions[3]" :qnum="4"></survey-question-header>
        <ValidationProvider name="チェックアウト日" :rules="{ required: dateRequired }" v-slot="{ errors }">
          <div class="form-group mt-2 position-relative">
            <datetime
              input-class="form-control btn border border-light text-left"
              type="date"
              :phrases="{ ok: '確定', cancel: '閉じる' }"
              placeholder="チェックアウト日を選択してください"
              value-zone="Asia/Tokyo"
              zone="Asia/Tokyo"
              :name="`answers[${4}][answer]`"
              v-model="dateAnswer"
              :readonly="verifyReservation"
            ></datetime>
            <i class="dripicons-chevron-down dropdown-icon"></i>
          </div>
          <error-message :message="errors[0]"></error-message>
        </ValidationProvider>
      </div>
      <div>
        <survey-question-header :question="survey.questions[4]" :qnum="5"></survey-question-header>
        <ValidationProvider name="答え" :rules="{ required: true, max: 255 }" v-slot="{ errors }">
          <input
            type="text"
            :name="`answers[${5}][answer]`"
            class="form-control mt-2"
            placeholder="入力してください"
            v-model.trim="answers[5].answer"
          />
          <error-message :message="errors[0]"></error-message>
        </ValidationProvider>
      </div>
      <div>
        <survey-question-header :question="survey.questions[5]" :qnum="6"></survey-question-header>
        <ValidationProvider name="答え" rules="required" v-slot="{ errors }">
          <select class="form-control w-100" :name="`answers[${6}][answer]`" v-model="answers[6].answer">
            <option v-for="(option, index) in survey.questions[5].content.options" :key="index" :value="index">
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
    survey: {
      type: Object
    },
    answers: {
      type: Object
    },
    haveApiKey: {
      type: Boolean
    },
    dateRequired: {
      type: Boolean
    }
  },

  components: {
    Datetime
  },

  data() {
    return {
      dateAnswer: null
    };
  },

  mounted() {
    if (this.verifyReservation) {
      const elements = document.querySelectorAll('.vdatetime > div');
      const firstTwoElements = Array.prototype.slice.call(elements, 0, 2);
      firstTwoElements.forEach(element => {
        element.remove();
      });
    }
  },

  created() {
    if (this.answers && this.answers[4].answer) {
      this.dateAnswer = this.answers[4].answer;
    }
  },

  computed: {
    verifyReservation() {
      return !!this.answers[1].answer;
    }
  },

  watch: {
    dateAnswer(newVal, oldVal) {
      if (newVal) {
        this.answers[4].answer = this.dateAnswer;
        this.$emit('update-required', true);
      }
    }
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
