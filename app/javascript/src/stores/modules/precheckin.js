import PrecheckinAPI from '../api/precheckin_api';

export const state = {
  precheckins: [],
  totalRows: 0,
  perPage: 0,
  queryParams: {
    page: 1,
    name_or_check_in_date_or_phone_number_cont: null
  }
};

export const mutations = {
  setMeta(state, meta) {
    state.totalRows = meta.total_count;
    state.perPage = meta.limit_value;
    state.curPage = meta.current_page;
  },

  setPrecheckins(state, precheckins) {
    state.precheckins = precheckins;
  },

  setQueryParams(state, params) {
    Object.assign(state.queryParams, params);
  }
};

export const actions = {
  async getPrecheckins(context) {
    try {
      const params = {
        page: state.queryParams.page,
        q: _.omit(state.queryParams, 'page')
      };
      const response = await PrecheckinAPI.list(params);
      context.commit('setPrecheckins', response.data);
      context.commit('setMeta', response.meta);
    } catch (error) {
      console.log(error);
    }
  }
};
