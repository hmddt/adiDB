import Vue from 'vue'
import Router from 'vue-router'
import HelloWorld from '@/components/HelloWorld'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      redirect:'/home'
    },
    {
      path:'/home', name:'home', component:() =>import('../view/home.vue')
    },
    {
      path:'/contact', name:'contact', component:() =>import('../view/Contact.vue')
    },
    {
      path:'/analysis', name:'analysis', component:() =>import('../view/analysis/analysis-con1.vue')
    },
    {
      path:'/listinformation', name:'listinformation', component:()=>import('../view/listinformation.vue')
    },
    {
      path:'/browser', name:'browser', component:() =>import('../view/list.vue')
    },
    {
      path:'/drug' , name:'drug' , component:()=>import('../view/genedetail/GeneDrug.vue')
    },
    {
      path:'/disease' , name:'disease' , component:()=>import('../view/genedetail/GeneDisease.vue')
    },
    {
      path:'/TF' , name:'TF' , component:()=>import('../view/Network/TF-gene.vue')
    },
    {
      path:'/ncRNA' , name:'ncRNA' , component:() =>import('../view/Network/ncRNA-gene.vue')
    },
    {
      path:'/dataset' , name:'dataset' ,component:()=>import('../view/genedetail/dataset.vue')
    },
    {
      path:'/sl' , name:'sl' , component:()=>import('../view/Network/SL.vue')
    },
    {
      path:'/immune' , name:'immune' , component:()=>import('../view/analysis/immune/immune-con1.vue')
    },
    {
      path:'/maind' , name:'maind' , component:()=>import('../view/analysis/drug/drug-con1.vue')
    },
  //   test
    {
      path:'/3Dmol' , name:'2dmol' , component:()=>import('../view/genedetail/3Dmol.vue')
    },
    {
      path:'/test' , name:'test' , component:() => import('../view/test.vue')
    },
    {
      path:'/evolution1' , name:'evolution1' , component:()=>import('../view/evolution/evolution.vue')
    },
    {
      path:'/help' , name:'help' , component:()=>import('../view/help/help.vue')
    },
    {
      path:'/NCRNAgene' , name:'NCRNAgene' , component:()=>import('../view/genedetail/ncRNA.vue')
    },
    {
      path:'/sequence' , name:'sequence' , component:()=>import('../view/SequenceLogo/sequencecon1.vue')
    },
    {
      path:'/testsl' , name:'testsl' , component:()=>import('../view/test/NetworkGraph.vue')
    },
    {
      path:'/testlogo' , name:'testlogo' , component:()=>import('../view/SequenceLogo/SequenceLogo.vue')
    },
    {
      path:'/testlogo1' , name:'testlogo' , component:()=>import('../view/SequenceLogo/sequenceLogo2.vue')
    }
  ]
})
