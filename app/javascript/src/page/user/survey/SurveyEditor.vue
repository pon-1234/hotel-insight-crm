<template>
  <div>
    <div class="mxw-1200" :key="contentKey">
      <div class="card">
        <div class="card-header left-border"><h3 class="card-title">基本設定</h3></div>
        <div class="card-body">
          <!-- フォルダー -->
          <div class="form-group d-flex">
            <label class="fw-300">フォルダー</label>
            <div class="flex-grow-1">
              <select v-model="surveyData.folder_id" class="form-control fw-300">
                <option v-for="(folder, index) in folders" :key="index" :value="folder.id">
                  {{ folder.name }}
                </option>
              </select>
            </div>
          </div>

          <!-- フォームタイプ -->
          <div class="form-group d-flex">
            <label class="fw-300">フォームタイプ</label>
            <div class="flex-grow-1">
              <select v-model="surveyData.type" class="form-control fw-300" @change="onSurveyTypeChanged()">
                <option key="1" value="normal">空白フォーム</option>
                <option key="2" value="precheckin">事前チェックイン</option>
              </select>
            </div>
          </div>

          <div class="form-group d-flex">
            <label class="fw-300 mb-auto">フォーム名(管理用)<required-mark /></label>
            <div class="flex-grow-1">
              <ValidationProvider name="フォーム名(管理用)" rules="required|max:64" v-slot="{ errors }">
                <input
                  v-model.trim="surveyData.name"
                  type="text"
                  name="survey_name"
                  class="form-control"
                  placeholder="フォーム名(管理用)を入力してください"
                  maxlength="65"
                />
                <error-message :message="errors[0]"></error-message>
              </ValidationProvider>
            </div>
          </div>
          <div class="form-group d-flex">
            <label class="fw-300 mb-auto">タイトル<required-mark /></label>
            <div class="flex-grow-1">
              <ValidationProvider name="タイトル" rules="required|max:255" v-slot="{ errors }">
                <input
                  v-model.trim="surveyData.title"
                  type="text"
                  name="survey_title"
                  class="form-control"
                  placeholder="タイトルを入力してください"
                />
                <error-message :message="errors[0]"></error-message>
              </ValidationProvider>
            </div>
          </div>
          <div class="form-group d-flex">
            <label class="fw-300 mb-auto">説明<required-mark /></label>
            <div class="flex-grow-1">
              <ValidationProvider name="説明" rules="required|max:1000" v-slot="{ errors }">
                <textarea
                  rows="3"
                  v-model="surveyData.description"
                  type="text"
                  name="survey_description"
                  class="form-control flex-grow-1"
                  placeholder="説明を入力してください"
                  maxlength="1001"
                >
                </textarea>
                <error-message :message="errors[0]"></error-message>
            </ValidationProvider>
            </div>
          </div>
          <div class="form-group d-flex">
            <label class="fw-300 mb-auto">回答後の文章</label>
            <div class="flex-grow-1">
              <ValidationProvider name="回答後の文章" rules="max:1000" v-slot="{ errors }">
                <textarea
                  rows="2"
                  v-model="surveyData.success_message"
                  type="text"
                  name="survey_success_message"
                  class="form-control"
                  placeholder="回答後の文章を入力してください"
                  maxlength="1001"
                >
                </textarea>
                <error-message :message="errors[0]"></error-message>
              </ValidationProvider>
            </div>
          </div>

          <div class="form-group d-flex">
            <label class="fw-300 mb-auto">バナー</label>
            <div class="flex-grow-1">
              <input-image :imageUrl.sync="surveyData.banner_url"></input-image>
            </div>
          </div>

          <div class="custom-control custom-checkbox">
            <input
              type="checkbox"
              class="custom-control-input"
              id="repeatAnswerCheck"
              v-model.trim="surveyData.re_answer"
            />
            <label class="custom-control-label" for="repeatAnswerCheck">何度でも回答可能にする</label>
          </div>

          <div class="custom-control custom-checkbox" v-if="can_sync_ggsheet">
            <input
              type="checkbox"
              class="custom-control-input"
              id="syncToGoogleSheet"
              v-model.trim="surveyData.sync_to_ggsheet"
            />
            <label class="custom-control-label" for="syncToGoogleSheet">Googleスプレッドシート連携</label>
          </div>
        </div>
        <loading-indicator :loading="this.loading"></loading-indicator>
      </div>

      <div class="card">
        <div class="card-header left-border"><h3 class="card-title">質問一覧</h3></div>
        <div class="card-body">
          <survey-question-editor
            :data="surveyData.questions"
            name="survey-question-editor"
            @input="onQuestionsChanged($event)"
          >
          </survey-question-editor>
        </div>
        <loading-indicator :loading="this.loading"></loading-indicator>
      </div>

      <div class="card">
        <div class="card-header left-border"><h3 class="card-title">回答後のアクション</h3></div>
        <div class="card-body">
          <action-editor-custom
            name="survey-action"
            :value="surveyData.after_action"
            :requiredLabel="false"
            :showTitle="false"
            :showLaunchMessage="false"
            @input="surveyData.after_action = $event"
          ></action-editor-custom>
        </div>
        <loading-indicator :loading="this.loading"></loading-indicator>
      </div>

      <div class="card">
        <div class="card-body">
          <div class="btn btn-success mr-2" @click="submit()">保存＆公開</div>
          <div class="btn btn-outline-success mw-120" @click="submit(false)">下書き保存</div>
        </div>
      </div>
    </div>

    <survey-preview :survey="surveyData"></survey-preview>

    <modal-confirm
      title="公開後、編集できませんがよろしいでしょうか。"
      id="modal-publish"
      type="confirm"
      @input="submit(true)"
    />
  </div>
</template>

<script>
import Util from '@/core/util';
import { mapActions, mapState } from 'vuex';
import ViewHelper from '@/core/view_helper';

export default {
  props: ['survey_id', 'can_sync_ggsheet'],
  provide() {
    return { parentValidator: this.$validator };
  },
  data() {
    return {
      rootPath: process.env.MIX_ROOT_PATH,
      contentKey: 0,
      loading: true,
      surveyData: {
        id: null,
        folder_id: Util.getParamFromUrl('folder_id'),
        type: 'normal', // or: precheckin
        name: null,
        title: null,
        description: null,
        banner_url: null,
        questions: null,
        after_action: null,
        success_message: null,
        re_answer: true,
        sync_to_ggsheet: true,
        connected_to_ggsheet: false,
        google_oauth_code: ''
      }
    };
  },
  async beforeMount() {
    await this.getTags({ low: true });
    if (this.survey_id) {
      const response = await this.getSurvey(this.survey_id);
      this.parseSurvey(response);
      this.forceRerender();
    }
    await this.getSurveys();
    this.loading = false;
  },

  computed: {
    ...mapState('survey', {
      folders: state => state.folders
    })
  },

  methods: {
    ...mapActions('tag', ['getTags']),
    ...mapActions('survey', ['getSurvey', 'createSurvey', 'updateSurvey', 'delete', 'getSurveys']),

    forceRerender() {
      this.contentKey++;
    },

    parseSurvey(survey) {
      this.surveyData = _.cloneDeep(survey);
    },

    async validateForm() {
      const result = await this.$validator.validateAll();
      if (!result) {
        return ViewHelper.scrollToRequiredField(false);
      }
      return true;
    },

    async submit(published = true) {
      if (this.loading) return;
      this.loading = true;
      if (published) {
        const valid = await this.$validator.validateAll();
        if (!valid) {
          this.loading = false;
          return ViewHelper.scrollToRequiredField(false);
        }
      }

      // Authorize with google api if needed
      if (published && this.can_sync_ggsheet && this.surveyData.sync_to_ggsheet && !this.surveyData.connected_to_ggsheet) {
        this.surveyData.google_oauth_code = await this.$gAuth.getAuthCode();
      }

      const payload = _.pick(this.surveyData, [
        'id',
        'folder_id',
        'type',
        'name',
        'banner_url',
        'title',
        'description',
        'success_message',
        're_answer',
        'after_action',
        'sync_to_ggsheet',
        'google_oauth_code'
      ]);
      payload.status = published ? 'published' : 'draft';
      payload.survey_questions_attributes = this.surveyData.questions.map((question, index) => {
        question.order = index;
        return question;
      });
      let response = null;
      if (this.survey_id) {
        response = await this.updateSurvey(payload);
      } else {
        response = await this.createSurvey(payload);
      }
      if (response) {
        Util.showSuccessThenRedirect(
          '回答フォームの保存は完了しました。',
          `${this.rootPath}/user/surveys?folder_id=${this.surveyData.folder_id}`
        );
      } else {
        window.toastr.error('回答フォームの保存は失敗しました。');
      }
    },

    onQuestionsChanged(questions) {
      this.surveyData.questions = questions;
    },

    onSurveyTypeChanged() {
      console.log('On survey changed: ', this.surveyData.type);
      this.surveyData.questions = this.PrecheckinQuestions;
      this.forceRerender();
    }
  }
};
</script>
<style lang="scss" scoped>
  ::v-deep {
    .btn-link {
      text-transform: uppercase;
      background: #00b900;
      border: 1px solid #00b900;
      color: #ffffff;
      font-weight: bold;
      font-size: 16pt;
      padding-left: 30px;
      padding-right: 30px;
    }
    .btn-submit {
      text-transform: uppercase;
      width: initial;
      min-width: 100px;
    }
    .btn-confirm {
      text-transform: uppercase;
      background: white;
      border: 1px solid #00b900;
      color: #00b900;
    }
    .survey {
      border: 1px solid #dedede;
      border-radius: 4px;
      padding: 10px;
    }
  }
</style>
