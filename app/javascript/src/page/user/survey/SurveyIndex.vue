<template>
  <div class="card">
    <div class="card-body">
      <div class="d-flex">
        <folder-left
          type="survey"
          :data="folders"
          :selectedFolder="selectedFolderIndex"
          @changeSelectedFolder="changeSelectedFolder"
          @submitUpdateFolder="submitUpdateFolder"
          @submitCreateFolder="submitCreateFolder"
        ></folder-left>
        <div class="flex-grow-1" :key="contentKey">
          <a
            :href="`${rootPath}/user/surveys/new?folder_id=${curFolder ? curFolder.id : null}`"
            class="btn btn-primary"
          >
            <i class="uil-plus"></i> 新規作成
          </a>
          <div class="mt-2">
            <table class="table table-centered mb-0">
              <thead class="thead-light">
                <tr>
                  <th>状況</th>
                  <th>フォーム名</th>
                  <th>フォームタイプ</th>
                  <th>回答状態</th>
                  <th></th>
                </tr>
              </thead>
              <tbody v-if="curFolder">
                <tr v-for="(survey, index) in curFolder.surveys" v-bind:key="index">
                  <td class="mw-120">
                    <survey-status :status="survey.status"></survey-status>
                  </td>
                  <td>
                    <div class="mxvw-15 max-2-lines">{{ survey.name }}</div>
                  </td>
                  <td class="mw-120">
                    <survey-type :surveyType="survey.type"></survey-type>
                  </td>
                  <td class="mw-200">
                    <template v-if="survey.responses_count === 0"> 未回答 </template>
                    <template v-else>
                      {{ survey.responses_count }}回答／<span class="font-12">{{ survey.users_count }}人</span>
                      <a :href="`${rootPath}/user/surveys/${survey.id}`" class="btn btn-sm btn-light ml-2">表示</a>
                    </template>
                    <a :href="survey.ggsheet_url" v-if="survey.ggsheet_url" target="_blank" class="fw-100"><img src="/img/ggsheet.png" width="35"/></a>
                  </td>
                  <td class="mw-200">
                    <div class="btn-group">
                      <button
                        type="button"
                        class="btn btn-light btn-sm dropdown-toggle"
                        data-toggle="dropdown"
                        aria-expanded="false"
                      >
                        操作 <span class="caret"></span>
                      </button>
                      <div class="dropdown-menu">
                        <a
                          role="button"
                          class="dropdown-item"
                          :href="`${rootPath}/user/surveys/${survey.id}/edit`"
                          v-if="survey.status !== 'published' && survey.editable"
                          >回答フォームを編集</a
                        >
                        <a
                          role="button"
                          class="dropdown-item"
                          :href="`${rootPath}/user/surveys/${survey.id}/export`"
                          >回答一覧DL</a
                        >
                        <a
                          role="button"
                          class="dropdown-item"
                          data-toggle="modal"
                          data-target="#modalCopySurvey"
                          @click="curSurveyIndex = index"
                          >回答フォームをコピー</a
                        >
                        <a
                          role="button"
                          class="dropdown-item"
                          data-toggle="modal"
                          data-target="#modalToggleSurvey"
                          @click="curSurveyIndex = index"
                          v-if="survey.status !== 'draft'"
                          >{{ survey.status === "published" ? "非公開" : "公開" }}にする</a
                        >
                        <a
                          role="button"
                          class="dropdown-item"
                          data-toggle="modal"
                          data-target="#modalDeleteSurvey"
                          @click="curSurveyIndex = index"
                          v-if="survey.destroyable"
                          >回答フォームを削除</a
                        >
                      </div>
                    </div>
                    <div
                      class="btn btn-sm btn-light my-1"
                      data-toggle="modal"
                      data-target="#modalSurveyPreview"
                      @click="curSurveyIndex = index"
                    >
                      プレビュー
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
            <div class="text-center mt-5" v-if="!curFolder || curFolder.surveys.length === 0">
              <b>回答フォームはありません。</b>
            </div>
          </div>
        </div>
      </div>
    </div>

    <loading-indicator :loading="loading"></loading-indicator>

    <!-- START: Delete folder modal -->
    <modal-confirm
      id="modalDeleteFolder"
      title="このフォルダーを削除してもよろしいですか？"
      type="delete"
      @confirm="submitDeleteFolder"
    >
      <template v-slot:content v-if="curFolder">
        <span>フォルダ名：{{ curFolder.name }}</span>
      </template>
    </modal-confirm>
    <!-- END: Delete folder modal -->

    <modal-confirm
      title="この回答フォームをコピーしてもよろしいですか？"
      id="modalCopySurvey"
      type="confirm"
      @confirm="submitCopySurvey"
    >
      <template v-slot:content v-if="curSurvey">
        <span>回答フォーム名：{{ curSurvey.name }}</span>
      </template>
    </modal-confirm>
    <modal-confirm
      title="この回答フォームを削除してもよろしいですか？"
      id="modalDeleteSurvey"
      type="delete"
      @confirm="submitDeleteSurvey"
    >
      <template v-slot:content v-if="curSurvey">
        <span>回答フォーム名：{{ curSurvey.name }}</span>
      </template>
    </modal-confirm>

    <!-- START: modal enable/disable richmenu -->
    <modal-confirm
      :title="`この回答フォームの状況を変更してもよろしいですか？`"
      id="modalToggleSurvey"
      type="confirm"
      @confirm="submitToggleSurvey"
    >
      <template v-slot:content v-if="curSurvey">
        状況変更：<b>{{ curSurvey.status === "published" ? "公開" : "非公開" }}</b>
        <i class="mdi mdi-arrow-right-bold"></i> <b>{{ curSurvey.status === "published" ? "非公開" : "公開" }}</b>
      </template>
    </modal-confirm>
    <!-- END: modal delete richmenu -->

    <!-- START: modal survey preview -->
    <modal-survey-preview :survey_id="curSurvey.id" v-if="curSurvey"></modal-survey-preview>
    <!-- END: modal survey preview -->
  </div>
</template>

<script>
import { mapActions, mapState } from 'vuex';
import Util from '@/core/util';

export default {
  data() {
    return {
      rootPath: process.env.MIX_ROOT_PATH,
      loading: true,
      contentKey: 0,
      surveysData: [],
      selectedFolderIndex: 0,
      curSurveyIndex: 0,
      surveyContents: 0,
      survey: null,
      textSearch: null
    };
  },
  async beforeMount() {
    await this.getSurveys();
    const folderId = Util.getParamFromUrl('folder_id');
    setTimeout(() => {
      if (folderId) {
        const index = _.findIndex(this.folders, _ => _.id === Number.parseInt(folderId));
        if (index >= 0) {
          this.changeSelectedFolder(index);
        }
      }
    }, 0);
    this.loading = false;
  },

  computed: {
    ...mapState('survey', {
      folders: state => state.folders
    }),

    curFolder() {
      return this.folders[this.selectedFolderIndex];
    },

    curSurvey() {
      return this.curFolder ? this.curFolder.surveys[this.curSurveyIndex] : null;
    }
  },

  methods: {
    ...mapActions('survey', [
      'createFolder',
      'updateFolder',
      'deleteFolder',
      'getSurveys',
      'copySurvey',
      'deleteSurvey',
      'toggleStatus'
    ]),
    forceRerender() {
      this.contentKey++;
    },

    changeSelectedFolder(index) {
      this.selectedFolderIndex = index;
    },

    async submitUpdateFolder(folder) {
      const response = await this.updateFolder(folder);
      if (response) {
        window.toastr.success('フォルダーの変更は完了しました。');
      } else {
        window.toastr.error('フォルダーの変更は失敗しました。');
      }
    },

    async submitCreateFolder(folder) {
      const response = await this.createFolder(folder);
      if (response) {
        window.toastr.success('フォルダーの作成は完了しました。');
      } else {
        window.toastr.error('フォルダーの作成は失敗しました。');
      }
    },

    updateStatus(survey) {},

    async submitCopySurvey() {
      const response = await this.copySurvey(this.curSurvey.id);
      const url = `${this.rootPath}/user/surveys?folder_id=${this.curFolder.id}`;
      if (response) {
        Util.showSuccessThenRedirect('回答フォームのコピーは完成しました。', url);
      } else {
        window.toastr.error('回答フォームのコピーは失敗しました。');
      }
    },

    async submitDeleteSurvey() {
      if (!this.curSurvey) return;
      const response = await this.deleteSurvey(this.curSurvey.id);
      const url = `${this.rootPath}/user/surveys?folder_id=${this.curFolder.id}`;
      if (response) {
        Util.showSuccessThenRedirect('回答フォームの削除は完了しました。', url);
      } else {
        window.toastr.error('回答フォームの削除は失敗しました。');
      }
    },

    async submitToggleSurvey() {
      if (!this.curSurvey) return;
      const response = await this.toggleStatus(this.curSurvey.id);
      const url = `${this.rootPath}/user/surveys?folder_id=${this.curFolder.id}`;
      if (response) {
        Util.showSuccessThenRedirect('回答フォーム状況の変更は完了しました。', url);
      } else {
        window.toastr.error('回答フォーム状況の変更は失敗しました。');
      }
    },

    async submitDeleteFolder() {
      const response = await this.deleteFolder(this.curFolder.id);
      if (response) {
        window.toastr.success('フォルダーの削除は完了しました。');
        this.changeSelectedFolder(0);
      } else {
        window.toastr.error('フォルダーの削除は失敗しました。');
      }
    }
  }
};
</script>
