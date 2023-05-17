<template>
  <div>
    <label>アクション</label>
    <div>
      <select v-model="postbackType" class="w-100 form-control" @change="changeActionType" :disabled="immutable">
        <option v-for="(val, key) of types" :key="key" :value="key">{{ val }}</option>
      </select>
    </div>
    <div class="mt-2">
      <action-postback-text v-if="postbackType === 'text'" :action-data="content" :name="name" @input="updateContent">
      </action-postback-text>

      <action-postback-template v-if="postbackType === 'template'" :value="content" @input="updateContent" :name="name">
      </action-postback-template>

      <action-postback-scenario v-if="postbackType === 'scenario'" :value="content" :name="name" @input="updateContent">
      </action-postback-scenario>

      <action-postback-email v-if="postbackType === 'email'" :value="content" :name="name" @input="updateContent">
      </action-postback-email>

      <action-postback-tag v-if="postbackType === 'tag'" :value="content" :name="name" @input="updateContent">
      </action-postback-tag>

      <action-postback-reminder
        v-if="postbackType === 'reminder'"
        :action-data="content"
        :name="name"
        @input="updateContent"
      ></action-postback-reminder>

      <action-postback-scoring
        v-if="postbackType === 'scoring'"
        :action-data="content"
        :name="name"
        @input="updateContent"
      ></action-postback-scoring>

      <action-postback-assign-staff
        v-if="postbackType === 'assign_staff'"
        :action-data="content"
        :name="name"
        @input="updateContent"
      ></action-postback-assign-staff>
    </div>
  </div>
</template>
<script>
export default {
  props: {
    value: String,
    name: {
      type: String,
      default: 'action'
    },
    showTitle: {
      type: Boolean,
      default: true
    },
    requiredLabel: {
      type: Boolean,
      default: true
    },
    immutable: {
      type: Boolean,
      default: false
    }
  },
  inject: ['parentValidator'],

  data() {
    return {
      types: this.PostbackTypes,
      postbackType: null,
      content: null
    };
  },

  watch: {
    value: {
      handler(val) {
        this.setupData();
      },
      deep: true
    }
  },

  created() {
    this.$validator = this.parentValidator;
    this.setupData();
  },

  methods: {
    updateContent(content) {
      this.content = content;
      this.notifyDataChanged();
    },

    notifyDataChanged() {
      this.$emit('input', {
        type: this.postbackType,
        content: this.content
      });
    },

    changeActionType() {
      this.content = undefined;
      this.notifyDataChanged();
    },

    setupData() {
      if (this.value) {
        const data = this.value;
        this.content = data.content;
        this.postbackType = data.type || 'none';
      } else {
        this.postbackType = 'none';
      }
    }
  }
};
</script>
