<template>
  <div>
    <div class="card mvh-50">
      <div class="card-header d-flex justify-content-between flex-wrap">
        <div class="w-lg-100 w-xl-25 mb-lg-3 mb-xl-0">
          <a href="/user/friends/export" class="btn btn-outline-primary text-nowrap"
            ><i class="fas fa-download"></i> CSVダウンロード</a
          >
        </div>
        <div class="d-flex justify-content-end">
          <div class="filter-tester-accounts custom-control custom-checkbox mr-3 d-flex align-items-center">
            <input
              type="checkbox"
              :value="true"
              name="tester"
              id="search_tester_account"
              class="custom-control-input"
              v-model="selectOnlyTester"
            />
            <label for="search_tester_account" class="custom-control-label">テスターのみ</label>
          </div>

          <!-- START: Search form -->
          <div class="w-200 h-5 mr-1">
            <staff-selection
              ref="channelAssignment"
              :selected="queryParams.channel_assignee_id_eq"
              @select="setAssigneeParam"
            ></staff-selection>
          </div>
          <div class="d-flex text-nowrap">
            <div class="input-group app-search">
              <input
                type="text"
                class="form-control dropdown-toggle fw-250"
                placeholder="検索..."
                v-model="keyword"
                maxlength="64"
              />
              <span class="mdi mdi-magnify search-icon"></span>
              <div class="input-group-append">
                <div class="btn btn-primary" @click="loadFriend">検索</div>
              </div>
            </div>
            <div
              class="btn btn-primary text-nowrap ml-1 mr-1"
              data-backdrop="static"
              data-toggle="modal"
              data-target="#modalFriendSearch"
              @click="openModal()"
            >
              詳細検索
            </div>
          </div>
        </div>
        <!-- End: Search form -->
      </div>
      <div class="card-body">
        <friend-search-status></friend-search-status>
        <div>
          <table class="table table-centered mt-2 pc">
            <thead class="thead-light">
              <tr>
                <th>名前</th>
                <th class="d-none d-lg-table-cell">登録日時</th>
                <th class="d-none d-lg-table-cell mw-400">タグ</th>
                <th>状況</th>
                <th v-if="isAdmin" class="d-none d-lg-table-cell">担当者</th>
                <th class="d-none d-lg-table-cell">操作</th>
              </tr>
            </thead>
            <tbody v-for="(friend, index) in friends" :key="index">
              <tr @click="isMobile ? redirectToFriendDetail(friend) : ''">
                <td class="table-user d-flex align-items-center">
                  <img v-lazy="genAvatarImgObj(friend.line_picture_url)" alt="table-user" class="mr-2 rounded-circle" />
                  <p class="m-0">
                    {{ (friend.display_name || friend.line_name) | truncate(10)
                    }}<span class="badge badge-warning ml-1 pt-1" v-if="friend.tester">テスター</span>
                  </p>
                </td>
                <td class="d-none d-lg-table-cell">{{ formattedDatetime(friend.created_at) }}</td>
                <td class="d-none d-lg-table-cell mxw-300">
                  <friend-tag :tags="friend.tags"></friend-tag>
                </td>
                <td>
                  <friend-status
                    :status="friend.status"
                    :locked="friend.locked"
                    :visible="friend.visible"
                  ></friend-status>
                </td>
                <td v-if="isAdmin" class="d-none d-lg-table-cell fw-250">
                  <channel-assignment :channel="friend.channel"></channel-assignment>
                </td>
                <td class="d-none d-lg-table-cell">
                  <a :href="`${rootUrl}/user/friends/${friend.id}`" class="btn btn-sm btn-light">詳細</a>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="d-flex justify-content-center mt-4">
          <b-pagination
            v-if="totalRows > perPage"
            v-model="curPage"
            :total-rows="totalRows"
            :per-page="perPage"
            @change="loadFriend"
            aria-controls="my-table"
          ></b-pagination>
        </div>
        <div class="text-center my-5 font-weight-bold" v-if="!loading && totalRows === 0">データはありません。</div>
      </div>
      <loading-indicator :loading="loading"></loading-indicator>
    </div>
    <modal-friend-search
      :selectOnlyTester="selectOnlyTester"
      ref="modalFriendSearch"
      @changeSelectOnlyTester="changeSelectOnlyTester"
    ></modal-friend-search>
  </div>
</template>
<script>
import { mapActions, mapMutations, mapState } from 'vuex';
import Util from '@/core/util';

export default {
  props: {
    role: String
  },

  data() {
    return {
      rootUrl: process.env.MIX_ROOT_PATH,
      loading: true,
      window: {
        width: 0
      },
      oldStaffId: null,
      selectOnlyTester: false
    };
  },

  watch: {
    queryParams: {
      handler(val) {
        if (val.channel_assignee_id_eq !== this.oldStaffId) {
          this.oldStaffId = val.channel_assignee_id_eq;
          this.$refs.channelAssignment.findStaff(this.queryParams.channel_assignee_id_eq);
        }
      },
      deep: true
    },
    selectOnlyTester: function(newVal) {
      if (newVal) {
        this.setQueryParam({ tester_eq: true });
      } else {
        this.setQueryParam({ tester_eq: null });
      }
    }
  },

  created() {
    window.addEventListener('resize', this.handleResize);
    this.handleResize();
    this.oldStaffId = this.queryParams.channel_assignee_id_eq;
  },

  destroyed() {
    window.removeEventListener('resize', this.handleResize);
  },

  async beforeMount() {
    await this.getFriends();
    this.loading = false;
  },

  computed: {
    ...mapState('friend', {
      queryParams: state => state.queryParams,
      friends: state => state.friends,
      totalRows: state => state.totalRows,
      perPage: state => state.perPage
    }),

    curPage: {
      get() {
        return this.queryParams.page;
      },
      set(value) {
        this.setQueryParam({ page: value });
      }
    },

    keyword: {
      get() {
        return this.queryParams.line_name_or_display_name_cont;
      },

      set(value) {
        this.setQueryParam({ line_name_or_display_name_cont: value });
      }
    },

    status_eq: {
      get() {
        return this.queryParams.status_eq;
      },

      set(value) {
        this.setQueryParam({ status_eq: value });
      }
    },

    isMobile: function() {
      return this.window.width < 760;
    },

    isAdmin: function() {
      return this.role === 'admin';
    },

    isStaff: function() {
      return this.role === 'staff';
    }
  },
  methods: {
    ...mapMutations('friend', ['setQueryParams', 'setQueryParam']),
    ...mapActions('friend', ['getFriends']),

    formattedDatetime(time) {
      return Util.formattedDatetime(time);
    },

    resetSearch() {
      this.keyword = '';
      this.getFriends();
    },

    loadFriend() {
      this.$nextTick(async() => {
        this.setQueryParams(this.queryParams);
        this.loading = true;
        this.getFriends();
        this.loading = false;
      });
    },

    redirectToFriendDetail(friend) {
      window.location.href = `${this.rootUrl}/user/friends/${friend.id}`;
    },

    handleResize() {
      this.window.width = window.innerWidth;
    },

    genAvatarImgObj(url) {
      const avatarImgObj = {
        src: url,
        error: '/img/no-image-profile.png',
        loading: '/images/loading.gif'
      };
      return avatarImgObj;
    },

    openModal() {
      this.$refs.modalFriendSearch.showModal();
    },

    setAssigneeParam(id) {
      this.setQueryParam({ channel_assignee_id_eq: id });
    },
    changeSelectOnlyTester: function(newVal) {
      this.selectOnlyTester = newVal;
    }
  }
};
</script>
<style lang="scss" scoped>
  .text-ov {
    width: 100px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
  }
</style>
