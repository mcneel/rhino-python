module.exports =
class RhinoSettingsView
  constructor: (serializedState) ->
    # Create root element
    @element = document.createElement('div')
    @element.id = 'RhinoSettingsView'
    # @element.classList.add('hello-vue')

    # Create message element
    title = document.createElement('div')
    title.textContent = "Rhino Python Search Paths:"
    title.classList.add('title')
    @element.appendChild(title)

    ul = document.createElement('ul')
    li = document.createElement('li')
    li.setAttribute('v-repeat', 'paths')
    li.setAttribute('v-on', 'click: markdelete = !markdelete')
    li.setAttribute('class', "{{markdelete ? 'markdelete' : ''}}")
    # li.classList.add("{{markdelete ? 'markdelete' : ''}}")
    li.textContent = '{{content}}'
    ul.appendChild(li)
    @element.appendChild(ul)

    msg = document.createElement('div')
    msg.textContent = "click on a path to mark it for deletion"
    msg.classList.add('msg')
    @element.appendChild(msg)

    btn = document.createElement('button')
    btn.textContent = 'add path'
    btn.setAttribute('v-on', 'click: add')
    @element.appendChild(btn)

    btn = document.createElement('button')
    btn.textContent = 'save changes'
    btn.setAttribute('v-on', 'click: save')
    @element.appendChild(btn)

    # ul = document.createElement('ul')
    # li = document.createElement('li')
    # sp = document.createElement('span')
    # sp.textContent = '-'
    # sp.style.color = 'red'
    # li.appendChild(sp)
    # sp = document.createElement('span')
    # sp.textContent = '/thepath'
    # li.appendChild(sp)
    # #li.textContent = '/thepath'
    # ul.appendChild(li)
    # li = document.createElement('li')
    # li.textContent = '/theotherpath/on/my/fs/somewhere'
    # ul.appendChild(li)
    # @element.appendChild(ul)

    # ta = document.createElement('textarea')
    # ta.rows = 10
    # ta.cols = 50
    # @element.appendChild(ta)

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @element.remove()

  getElement: ->
    @element
