<template>
  <div>
    <div class="card mvh-50">
      <div class="card-header d-flex justify-content-end">
        <div class="d-flex text-nowrap">
          <div class="input-group app-search">
            <input
              type="text"
              class="form-control dropdown-toggle fw-250"
              placeholder="検索..."
              v-model="queryParams.name_or_check_in_date_or_phone_number_cont"
              maxlength="64"
            />
            <span class="mdi mdi-magnify search-icon"></span>
            <div class="input-group-append">
              <div class="btn btn-primary" @click="search()">検索</div>
            </div>
          </div>
        </div>
      </div>
      <div class="card-body">
        <div>
          <table class="table table-centered mt-2 pc">
            <thead class="thead-light">
              <tr>
                <th class="d-none d-lg-table-cell">チェックイン日</th>
                <th class="d-none d-lg-table-cell">チェックアウト日</th>
                <th>お名前</th>
                <th>電話番号</th>
                <th>住所</th>
                <th>誕生日</th>
                <th>ご利用シーン</th>
                <th>性別</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="(precheckin, index) in precheckins" :key="index">
                <td class="fw-150">{{ formatDate(precheckin.check_in_date) }}</td>
                <td class="fw-150">{{ formatDate(precheckin.check_out_date) }}</td>
                <td>{{ precheckin.name }}</td>
                <td>{{ precheckin.phone_number }}</td>
                <td>{{ precheckin.address }}</td>
                <td>{{ formatDate(precheckin.birthdate) }}</td>
                <td>{{ companionOptions[precheckin.companion] }}</td>
                <td>{{ genders[precheckin.gender] }}</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="d-flex justify-content-center mt-4">
          <b-pagination
              v-if="totalRows > perPage"
              v-model="queryParams.page"
              :total-rows="totalRows"
              :per-page="perPage"
              @change="loadPage()"
              aria-controls="my-table"
            ></b-pagination>
        </div>
        <div class="text-center my-5 font-weight-bold" v-if="!loading && totalRows === 0">データはありません。</div>
      </div>
      <loading-indicator :loading="loading"></loading-indicator>
    </div>
  </div>
</template>

<script>
import { mapActions, mapMutations, mapState } from 'vuex';
import moment from 'moment';

export default {
  props: {
    role: String
  },

  data() {
    return {
      loading: true,
      genders: ['男性', '女性', 'その他', '回答しない'],
      companionOptions: {
        single: '一人旅',
        couple: '恋人と',
        friends: '友達と',
        family: '家族と',
        business: 'ビジネス',
        other: 'その他'
      }
    };
  },

  async beforeMount() {
    await this.getPrecheckins();
    this.loading = false;
  },

  computed: {
    ...mapState('precheckin', ['queryParams', 'precheckins', 'totalRows', 'perPage'])
  },
  methods: {
    ...mapMutations('precheckin', ['setQueryParams']),
    ...mapActions('precheckin', ['getPrecheckins']),

    forceRerender() {
      this.contentKey++;
    },

    search() {
      this.queryParams.page = 0;
      this.loadPage();
    },

    formatDate(date) {
      return moment(date, 'YYYY-MM-DD').format('YYYY年MM月DD日');
    },

    async loadPage() {
      this.$nextTick(async() => {
        this.setQueryParams(this.queryParams);
        this.loading = true;
        await this.getPrecheckins();
        this.forceRerender();
        this.loading = false;
      });
    }
  }
};
</script>
