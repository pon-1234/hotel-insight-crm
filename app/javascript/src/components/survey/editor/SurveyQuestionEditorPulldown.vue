<template>
  <div class="survey">
    <div class="form-group clearfix d-flex">
      <label class="fw-200">項目名<required-mark /></label>
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

    <div class="d-flex">
      <span class="fw-200">選択肢</span>
      <div class="flex-grow-1">
        <!-- START: checkbox options -->
        <div v-for="(item, index) of options" :key="index" class="card border-info border">
          <div class="card-header d-flex">
            <div>選択肢 {{ index + 1 }}</div>
            <div class="ml-auto">
              <div v-if="!immutable">
                <div @click="moveUpObject(index)" class="btn btn-sm btn-light" v-if="index > 0">
                  <i class="dripicons-chevron-up"></i>
                </div>
                <div @click="moveDownObject(index)" class="btn btn-sm btn-light" v-if="index < options.length - 1">
                  <i class="dripicons-chevron-down"></i>
                </div>
                <div @click="removeObject(index)" v-if="options.length > 1" class="btn btn-sm btn-light">
                  <i class="mdi mdi-delete"></i>
                </div>
              </div>
            </div>
          </div>
          <div class="card-body">
            <div class="form-group d-flex">
              <span class="fw-200">ラベル<required-mark /></span>
              <input
                class="form-control flex-grow-1"
                type="text"
                aria-label="Option Label"
                aria-describedby="basic-addon1"
                v-validate="'required'"
                :name="name + '-value-' + index"
                v-model.trim="item.value"
                placeholder="ラベルを入力してください"
                :readonly="immutable"
              />
            </div>
            <div class="form-group d-flex mt-2">
              <div class="fw-200 pr-2">
                <span class="fw-200">選択時のアクション</span>
              </div>
              <div style="width: calc(100% - 200px)" :key="contentKey">
                <div class="action-postback">
                  <action-postback
                    :showTitle="false"
                    :value="item.action"
                    :name="name + '-postback-' + index"
                    :requiredLabel="false"
                    @input="item.action = $event"
                    :immutable="immutable"
                  ></action-postback>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="mt-2">
          <div @click="addItem()" v-if="options.length < max && !immutable" class="btn btn-info">
            <i class="uil-plus"></i> 選択肢追加
          </div>
        </div>
      </div>
      <!-- END: checkbox options -->
    </div>
  </div>
</template>

<script>
export default {
  props: ['content', 'name', 'immutable'],
  data() {
    return {
      max: 50,
      contentKey: 0,
      value: this.content || {
        text: null,
        sub_text: null,
        name: this.name,
        options: [
          {
            value: null,
            action: {
              type: 'none'
            }
          }
        ]
      }
    };
  },
  inject: ['parentValidator'],

  created() {
    this.$validator = this.parentValidator;
    this.value.name = this.name;
    this.syncObj();
  },

  computed: {
    options() {
      return this.value ? this.value.options : [];
    }
  },

  methods: {
    forceRerender() {
      this.contentKey++;
    },

    syncObj() {
      this.forceRerender();
      this.$emit('input', this.value);
    },
    addItem() {
      this.options.push({
        value: null,
        action: {
          type: 'none'
        }
      });
      this.syncObj();
    },
    moveUpObject(index) {
      if (index > 0) {
        const to = index - 1;
        this.options.splice(to, 0, this.options.splice(index, 1)[0]);
        this.syncObj();
      }
    },
    moveDownObject(index) {
      if (index < this.options.length) {
        const to = index + 1;
        this.options.splice(to, 0, this.options.splice(index, 1)[0]);
        this.syncObj();
      }
    },
    removeObject(index) {
      this.options.splice(index, 1);
      this.syncObj();
    }
  }
};
</script>
