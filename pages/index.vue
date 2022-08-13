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
        <div class="delete">
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
  </div>
</template>

<script>
import PouchDB from 'pouchdb'
import PouchDBFind from 'pouchdb-find'

export default {
  name: 'IndexPage',

  data () {
    return {
      db: {},
      recentCards: [
        { title: 'create your first note' }
      ],
      olderCards: [
        { title: 'no older cards yet!' }
      ]
    }
  },

  methods: {
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
  }
}
</script>
