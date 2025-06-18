<template>
  <div class="contact">
    <div class="box-card" style="position: relative">
      <div style="text-align: left;margin-top: 40px">
        <span style="font-size: 20px;font-weight: bold;color:#3a8ee6;margin-left: 100px">Contact us</span>
      </div>

      <hr style="margin-left: 100px;margin-top: 30px;margin-bottom: 30px">
      <div class="contact-content" style="margin-left:  100px;text-align: left;font-size: 16px">
        <p>
          If you have questions about our database or other suggestions, you can contact us using the following methods.
        </p>
        <br style="height: 200px">
        <span style="font-weight: bold">E-mail</span>
        <p>lguo@njupt.edu.cn</p>
        <br style="height: 200px">
        <span style="font-weight: bold">Address</span>
        <p>
          Department of Bioinformatics, </p>
        <p>Smart Health Big Data Analysis and Location Services Engineering Lab of Jiangsu Province,
        </p>
        <p>
          School of Geographic and Biologic Information,
        </p>
        <p>Nanjing University of Post and Telecommunication
        </p >
        <p>
          Nanjing 210023, Jiangsu Province, China
        </p>

      </div>

    </div>
  </div>
</template>

<script>
import Footer from "./footer.vue";

export default {
  name: "Contact",
  components: {Footer}
}
</script>

<style scoped>
.box-card {
  margin-top: 100px;
  margin-bottom: 260px;
  border-radius: 20px;


}
p{
  color: #2c3e50;
}
.contact{
  padding: 20px;
  border-style: solid;
  margin: 0 auto;
  width: 1400px;
  border-color: rgba(168,168,168,0);
}
</style>
