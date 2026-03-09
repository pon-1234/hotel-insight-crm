<template>
  <div>
    <div v-show="added_friend_before == 'true'">
      <div class="alert alert-success" role="alert">
        <h4 class="alert-heading">リンクが完了しました</h4>
        <p class="py-2">
          ありがとうございました！
        </p>
        <hr>
        <p class="mb-0">上部✖︎ボタンを押して終了してください</p>
      </div>
    </div>
    <div v-show="notAddFriend">
      <div class="alert alert-warning alert-dismissible fade show" role="alert">
        {{ errorMessage }}
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
          <span aria-hidden="true">&times;</span>
        </button>
      </div>
    </div>
  </div>
</template>
<script>
import liff from '@line/liff';

export default {
  props: ['liff_id', 'stream_route_code', 'friendship_status_changed', 'added_friend_before'],
  data() {
    return {
      rootPath: process.env.MIX_ROOT_PATH,
      notAddFriend: false,
      errorMessage: 'リンクに失敗しました。時間を空けて再度お試しください。'
    };
  },

  created() {
    // When populate stream_route_code into redirectUri of liff.login,
    // redundant callback request is generated from liff lead to not expect errors happen
    // So use localStorage to save stream_route_code for using to another requests later
    if (this.stream_route_code) localStorage.setItem('currentStreamRouteCode', this.stream_route_code);
    if (this.liff_id) localStorage.setItem('currentLiffId', this.liff_id);
  },

  mounted() {
    if (this.added_friend_before === 'true') {
      liff.closeWindow();
      return;
    }
    const liffId = (this.liff_id || localStorage.getItem('currentLiffId') || '').trim();
    if (!liffId) {
      this.notAddFriend = true;
      this.errorMessage = 'LIFF ID が未設定です。管理画面で LIFF ID を設定してください。';
      return;
    }
    liff.init({ liffId: liffId })
      .then(() => {
        if (!liff.isLoggedIn()) {
          liff.login({ bot_prompt: 'aggressive' });
        } else {
          liff.getFriendship().then((data) => {
            // in case added officer account as friend
            if (data.friendFlag) {
              const userId = liff.getContext().userId;
              if (this.friendship_status_changed === 'true') {
                // for first time officer account is added as friend
                const currentStreamRouteCode = localStorage.getItem('currentStreamRouteCode');
                if (!currentStreamRouteCode) {
                  this.notAddFriend = true;
                  this.errorMessage = '流入経路コードを取得できませんでした。再度リンクを開いてください。';
                  return;
                }
                localStorage.removeItem('currentStreamRouteCode');
                localStorage.removeItem('currentLiffId');
                window.location.href = `${this.rootPath}/stream_route_detail/${currentStreamRouteCode}?line_user_id=${userId}&friendship_status_changed=true&added_friend_before=true`;
              } else {
                // nexttime when stream route link is accessed
                // Only available when chose アクションの実行 -> いつでも
                // need to add added_friend_before param to avoid infinite loop
                const currentStreamRouteCode = localStorage.getItem('currentStreamRouteCode');
                if (!currentStreamRouteCode) {
                  this.notAddFriend = true;
                  this.errorMessage = '流入経路コードを取得できませんでした。再度リンクを開いてください。';
                  return;
                }
                localStorage.removeItem('currentStreamRouteCode');
                localStorage.removeItem('currentLiffId');
                window.location.href = `${this.rootPath}/stream_route_detail/${currentStreamRouteCode}?line_user_id=${userId}&added_friend_before=true`;
              }
            } else {
              // if have not add officer account as friend yet then logout
              // User need remove app connection from line app before add officer account from stream route link one more time
              // Maybe need create a popup to explain and guide for users
              localStorage.removeItem('currentStreamRouteCode');
              localStorage.removeItem('currentLiffId');
              liff.logout();
              this.notAddFriend = true;
            }
          }, () => {
            liff.logout();
            liff.login({ bot_prompt: 'aggressive' });
          });
        }
      })
      .catch((err) => {
        console.log(err);
        this.notAddFriend = true;
        this.errorMessage = 'LIFF の初期化に失敗しました。URL と LIFF ID の設定を確認してください。';
      });
  }
};
</script>
