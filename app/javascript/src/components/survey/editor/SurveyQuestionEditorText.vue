<template>
  <div class="survey">
    <div class="form-group clearfix d-flex">
      <span class="fw-200">項目名<required-mark /></span>
      <div class="flex-grow-1">
        <input
          v-model.trim="value.text"
          type="text"
          :name="name + '-text'"
          class="form-control"
          maxlength="256"
          placeholder="項目名を入力してください"
          v-validate="'required|max:255'"
          data-vv-as="項目名"
          :readonly="immutable"
        />
        <error-message :message="errors.first(name + '-text')"></error-message>
      </div>
    </div>
    <div class="form-group clearfix d-flex">
      <div class="fw-200 d-flex align-items-center">
        <span>補足文</span>
        <div v-b-tooltip.hover title="回答入力欄の下に表示されます" class="ml-2">
          <i class="text-md far fa-question-circle"></i>
        </div>
      </div>
      <div class="flex-grow-1">
        <input
          v-model.trim="value.sub_text"
          :name="name + '-subtext'"
          type="text"
          class="form-control"
          placeholder="補足文を入力してください"
          maxlength="256"
          v-validate="'max:255'"
          data-vv-as="補足文"
          :readonly="immutable"
        />
        <error-message :message="errors.first(name + '-subtext')"></error-message>
      </div>
    </div>
    <div class="form-group clearfix d-flex">
      <span class="fw-200">回答の情報登録</span>
      <div class="flex-grow-1">
        <survey-variable-config
          type="text"
          :field="value.variable ? value.variable.name : null"
          :name="name + '-infomation'"
          @input="value.variable = $event"
        ></survey-variable-config>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: ['content', 'name', 'immutable'],
  data() {
    return {
      value: this.content || {
        name: this.name,
        text: null,
        sub_text: null
      }
    };
  },
  inject: ['parentValidator'],

  created() {
    this.$validator = this.parentValidator;
    this.value.name = this.name;
    this.syncObj();
  },
  watch: {
    content(val) {
      this.value = val || {
        name: this.name,
        text: null,
        sub_text: null
      };
    }
  },
  methods: {
    syncObj() {
      this.$emit('input', this.value);
    }
  }
};
</script>
