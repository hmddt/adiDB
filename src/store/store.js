import Vue from 'vue';
import Vuex from 'vuex';

Vue.use(Vuex);

export default new Vuex.Store({
  state: {
    geneDiseaseData: []
  },
  mutations: {
    setGeneDiseaseData(state, data) {
      state.geneDiseaseData = data;
    }
  },
  actions: {
    loadGeneDiseaseData({ commit }) {
      import('../../datajs/gene-disData.json')
        .then(module => {
          commit('setGeneDiseaseData', module.default); //  确保这里的数据格式正确
        })
        .catch(error => console.error('加载 geneDiseaseData 失败:', error));
    }
  }
});
