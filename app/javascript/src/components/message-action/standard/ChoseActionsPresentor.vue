<template>
  <div class="d-inline-block chose-actions-presentor align-middle" v-if="actions.length > 0">
    <div class="fw-200 text-truncate chose-actions-presentor-main" v-html="willBeShowedActions"></div>
  </div>
  <div v-else>なし</div>
</template>

<script>
export default {
  props: {
    actions: {
      type: Array,
      default: () => []
    }
  },
  computed: {
    willBeShowedActions: function() {
      let result = '';
      this.actions.forEach(action => {
        switch (action.type) {
        case 'text':
          result += `テキスト[${action.content.text}]を送信 <br>`;
          break;
        case 'template':
          result += `テンプレート[${action.content.name}]を送信 <br>`;
          break;
        case 'scenario':
          result += `シナリオ[${action.content.title}]を送信 <br>`;
          break;
        case 'email':
          result += `メール通知[${action.content.text}]を送信 <br>`;
          break;
        case 'tag':
          result += 'タグ操作を送信 <br>';
          break;
        case 'reminder':
          result += `リマインダ操作[${action.content.reminder.name}]を送信 <br>`;
          break;
        case 'scoring':
          result += `スコアリング操作[${action.content.variable.name}]を送信 <br>`;
          break;
        // case 'precheckin':
        //   result += '予約・事前チェックインを送信 <br>';
        //   break;
        case 'rsv_intro':
          result += '予約・紹介送信を送信 <br>';
          break;
        case 'rsv_contact':
          result += '予約・お問い合わせを送信 <br>';
          break;
        case 'rsv_cancel_intro':
          result += '予約・空室待ちキャンセルを送信 <br>';
          break;
        // case 'service_review':
        //   result += 'サービス評価フォームを送信 <br>';
        //   break;
        }
      });
      return result;
    }
  }
};
</script>

<style lang="scss" scoped>
  @media screen and (max-width: 1366px) {
    .chose-actions-presentor {
      .chose-actions-presentor-main {
        width: 150px !important;
        max-width: 150px !important;
        min-width: 150px !important;
      }
    }
  }
</style>
