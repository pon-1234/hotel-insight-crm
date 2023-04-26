import SurveyAPI from '../api/survey_api';
import FolderAPI from '../api/folder_api';

export const state = {
  folders: [],
  users: [],
  responses: [],
  usersTotalRows: 0,
  usersPerPage: 0,
  usersCurPage: 0,
  responsesTotalRows: 0,
  responsesPerPage: 0,
  responsesCurPage: 0,
  datetimeQuestion: {},
  datetimeRequired: {}
};

export const mutations = {
  pushFolder(state, folder) {
    folder.surveys = [];
    state.folders.push(folder);
  },

  setFolders(state, folders) {
    state.folders = folders;
  },

  updateFolder(state, newItem) {
    const item = state.folders.find(item => item.id === newItem.id);
    if (item) {
      item.name = newItem.name;
    }
  },

  deleteFolder(state, id) {
    const index = state.folders.findIndex(_ => _.id === id);
    state.folders.splice(index, 1);
  },

  setUsers(state, users) {
    state.users = users;
  },

  setUsersMeta(state, meta) {
    state.usersTotalRows = meta.total_count;
    state.usersPerPage = meta.limit_value;
    state.usersCurPage = meta.current_page;
  },

  setResponses(state, responses) {
    state.responses = responses;
  },

  setResponsesMeta(state, meta) {
    state.responsesTotalRows = meta.total_count;
    state.responsesPerPage = meta.limit_value;
    state.responsesCurPage = meta.current_page;
  },

  setDatetimeQuestion(state, question) {
    state.datetimeQuestion = {
      ...state.datetimeQuestion,
      [question.ques_num]: question.ques
    };
  },

  setDatetimeRequired(state, question) {
    state.datetimeRequired = {
      ...state.datetimeRequired,
      [question.ques_num]: question.status
    };
  }
};

export const getters = {
  getDatetimeRequired: (state) => (quesNum) => {
    return state.datetimeRequired[quesNum] || false;
  }
};

export const actions = {
  async createFolder(context, payload) {
    try {
      const folder = await FolderAPI.create(payload);
      context.commit('pushFolder', folder);
      return folder;
    } catch (error) {
      return null;
    }
  },

  async updateFolder(context, payload) {
    try {
      const response = await FolderAPI.update(payload);
      context.commit('updateFolder', response);
      return response;
    } catch (error) {
      return null;
    }
  },

  async deleteFolder(context, id) {
    try {
      const response = await FolderAPI.delete(id);
      context.commit('deleteFolder', id);
      return response;
    } catch (error) {
      return null;
    }
  },

  /**
   * Survey is belong to a folder, get all folders of current account
   * @param {Context} context store context
   * @param {Object} payload payload
   * @returns surveys in folders
   */
  async getSurveys(context, query) {
    try {
      const folders = await SurveyAPI.list(query);
      context.commit('setFolders', folders);
    } catch (error) {
      return null;
    }
  },

  /**
   * Get survey detail
   * @param {Context} context store context
   * @param {Object} payload payload
   * @returns survey
   */
  async getSurvey(_, id) {
    try {
      return await SurveyAPI.get(id);
    } catch (error) {
      return null;
    }
  },

  /**
   * Get survey by code
   * @param {Context} _  store context
   * @param {*} code  survey code
   * @returns survey
   */
  async getSurveyByCode(_, code) {
    try {
      return await SurveyAPI.getByCode(code);
    } catch (error) {
      return null;
    }
  },

  /**
   * Create a new survey
   * @param {Context} context store context
   * @param {Object} payload payload
   * @returns survey or null
   */
  async createSurvey(context, payload) {
    try {
      return await SurveyAPI.create(payload);
    } catch (error) {
      return null;
    }
  },

  /**
   * Update the survey
   * @param {Context} context store context
   * @param {Object} payload payload
   * @returns survey or null
   */
  async updateSurvey(context, payload) {
    try {
      return await SurveyAPI.update(payload);
    } catch (error) {
      return null;
    }
  },

  async postAnswer(context, payload) {
    try {
      return await SurveyAPI.postAnswer(payload);
    } catch (error) {
      return null;
    }
  },

  /**
   * Clone survey
   * @param {Context} context store context
   * @param {Number} id survey id
   */
  async copySurvey(context, id) {
    try {
      return await SurveyAPI.copy(id);
    } catch (error) {
      return null;
    }
  },

  /**
   * Delete survey
   * @param {Context} context store context
   * @param {Number} id survey id
   */
  async deleteSurvey(context, id) {
    try {
      return await SurveyAPI.delete(id);
    } catch (error) {
      return null;
    }
  },

  /**
   * Toggle survey status
   * @param {Context} context store context
   * @param {Number} id survey id
   */
  async toggleStatus(context, id) {
    try {
      return await SurveyAPI.toggleStatus(id);
    } catch (error) {
      return null;
    }
  },

  async getAnsweredUsers(context, query) {
    try {
      const response = await SurveyAPI.answeredUsers(query);
      context.commit('setUsers', response.data);
      context.commit('setUsersMeta', response.meta);
      return response;
    } catch (error) {
      return null;
    }
  },

  async getResponses(context, query) {
    try {
      const response = await SurveyAPI.responses(query);
      context.commit('setResponses', response.data);
      context.commit('setResponsesMeta', response.meta);
      return response;
    } catch (error) {
      return null;
    }
  },

  async getFriendResponses(context, query) {
    try {
      return await SurveyAPI.friendResponses(query);
    } catch (error) {
      return null;
    }
  }
};
