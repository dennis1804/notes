<template>
  <div class="confirm-dialog">
    <p>{{ dialog }}</p>
    <div class="buttons">
      <button
        class="cancel"
        @click="cancelCallback()"
      >
        CANCEL
      </button>
      <button
        class="confirm"
        @click="confirmCallback()"
      >
        CONFIRM
      </button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConfirmDialog',

  props: {
    dialog: String,
    cancelCallback: Function,
    confirmCallback: Function
  }

}

</script>
