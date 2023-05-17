<template>
  <div>
    <span v-if="surveyType === 'normal'">normal</span>
    <span v-else-if="surveyType === 'precheckin'">precheckin</span>
  </div>
</template>

<script>
export default {
  props: {
    surveyType: {
      type: String
    }
  }
};
</script>
