<template>
  <div class="container">
    <h1>Notes</h1>
    <div class="quick-menu">
      <nuxt-link
        v-for="card, index in recentCards"
        :key="index"
        class="card"
        :to="'/edit?uuid=' + card._id"
      >
        <h3>{{ card.title }}</h3>
        <span>{{ getReadableDate(card.changeDate) }}</span>
        <p> {{ card.body }} </p>
      </nuxt-link>
    </div>
    <nav>
      <ul>
        <li>&lt;</li>
        <li><h2>This Month</h2></li>
        <li>></li>
      </ul>
    </nav>
    <div class="list-layout">
      <nuxt-link
        v-for="card, index in olderCards"
        :key="index"
        class="list-card"
        :to="'/edit?uuid=' + card._id"
      >
        <h4>{{ card.title }}</h4>
        <span>{{ getReadableDate(card.changeDate) }}</span>
        <div
          class="delete"
          @click.prevent="showDeleteDialog(card)"
        >
          X
        </div>
      </nuxt-link>
    </div>
    <nuxt-link
      to="/edit"
      class="fab"
    >
      NEW
    </nuxt-link>
    <ConfirmDialog
      :class="{'visible': removeable._id}"
      :dialog="`Are you sure you want to delete ${removeable.title}?`"
      :cancel-callback="clearDelete"
      :confirm-callback="deleteElem"
    />
  </div>
</template>

<script>
import PouchDB from 'pouchdb'
import PouchDBFind from 'pouchdb-find'
import ConfirmDialog from '~/components/ConfirmDialog'

export default {
  name: 'IndexPage',

  components: {
    ConfirmDialog
  },
  transition: 'page-right',

  data () {
    return {
      db: {},
      removeable: {},
      recentCards: [
        { title: 'create your first note' }
      ],
      olderCards: [
        { title: 'no older cards yet!' }
      ]
    }
  },

  created () {
    PouchDB.plugin(PouchDBFind)
    this.db = new PouchDB('notes')
    const db = this.db
    this.getDBRecords(db, 2, 0).then((data) => {
      this.recentCards = data
    })
    this.getDBRecords(db, 10, 2).then((data) => {
      this.olderCards = data
    })
  },

  methods: {
    showDeleteDialog (item) {
      this.removeable = item
    },

    clearDelete () {
      this.removeable = {}
    },

    deleteElem () {
      const item = this.removeable
      const db = this.db
      db.get(item._id).then((doc) => {
        return db.remove(doc)
      })
      this.getDBRecords(db, 10, 2).then((data) => {
        this.olderCards = data
      })
      this.clearDelete()
    },

    getReadableDate (timestamp) {
      const date = new Date(timestamp)
      return date.toLocaleString([], { dateStyle: 'short', timeStyle: 'short' })
    },

    getDBRecords (db, limit = 5, skip = 0) {
      return db.createIndex({
        index: { fields: ['changeDate'] }
      }).then(function () {
        return db.find({
          selector: {
            changeDate: { $gte: null }
          },
          limit,
          skip,
          sort: [{ changeDate: 'desc' }]
        })
      }).then(data => data.docs)
    }
  }
}
</script>
