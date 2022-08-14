<template>
  <div class="container">
    <span
      v-if="pencil"
      class="pencil save-state"
    >
      changed
    </span>
    <span
      v-if="saved"
      class="pencil save-state"
    >
      saved
    </span>

    <h1>{{ option }} Note</h1>
    <form
      class="note-form"
      @submit.prevent="submitForm()"
      @input="formChange()"
    >
      <input
        v-model="formData.title"
        type="text"
        name="title"
        placeholder="title"
      >
      <textarea
        v-model="formData.body"
        name="body"
        placeholder="Note"
      />
    </form>
    <button
      class="delete note-action"
      @click="removeable = true"
    >
      X
    </button>
    <nuxt-link
      to="/"
      class="fab"
    >
      BACK
    </nuxt-link>
    <ConfirmDialog
      :class="{'visible': removeable}"
      :dialog="`Are you sure you want to delete ${formData.title}?`"
      :cancel-callback="clearDelete"
      :confirm-callback="deleteElem"
    />
  </div>
</template>

<script>
import PouchDB from 'pouchdb'

export default {
  name: 'EditPage',

  data () {
    return {
      db: {},
      option: 'New',
      removeable: false,
      formTimeout: null,
      pencil: false,
      saved: false,
      formData: {
        _id: this.$route.query?.uuid || this.uuidv4(),
        title: '',
        body: ''
      }
    }
  },

  created () {
    this.db = new PouchDB('notes')
    this.db.get(this.formData._id).then((doc) => {
      this.formData = doc
      this.option = 'Edit'
    })
  },

  methods: {
    submitForm () {
      navigator.vibrate(10)
      this.formData.changeDate = (new Date()).getTime()
      this.db.put(this.formData).then((doc) => {
        this.pencil = false
        this.formData._rev = doc.rev
        this.saved = true
        setTimeout(function () {
          this.saved = false
        }.bind(this), 300)
      })
    },
    formChange () {
      const that = this
      this.pencil = true
      if (this.timeout !== null) {
        clearTimeout(this.timeout)
      }
      this.timeout = setTimeout(function () {
        that.submitForm()
      }, 1000)
    },
    clearDelete () {
      this.removeable = false
    },
    deleteElem () {
      this.db.get(this.formData._id).then((doc) => {
        return this.db.remove(doc)
      })
      this.$router.push('/')
    },
    uuidv4 () {
      return ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, c =>
        (c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
      )
    }
  }
}
</script>
