---
layout: post
title: ! '用Webpack实现React Router组件的异步加载'
categories:
- Web
tags: [ReactJS, Web Development, Webpack]
status: publish
type: post
published: false
---

```js
const loadComponentAsync = loadChunk => (location, cb) => {
  cb(null, {loadChunk: loadChunk});
};

<Route
	name="创建积分项"
	path="additems"
	getComponent={loadComponentAsync(
	  require('bundle?lazy!./components/myinventorypool/CreateItemParent')
	)}
	onEnter={requireAuth}
/>
```

```js
module.exports = React.createClass({

  componentWillMount() {
    NProgress.start();
  },

  componentWillUnmount() {
    NProgress.done();
  },

  render() {
    return null;
  }
});
```

```js
const App = React.createClass({
  mixins: [FluxMixin, StoreWatchMixin('UserStore')],

  getStateFromFlux() {
    const flux = this.getFlux();
    const store = flux.store('UserStore');
    return {
      isLoggedIn: store.isLoggedIn(),
      fetchingUser: store.isFetchingUser(),
      user: store.getUser()
    };
  },

  getInitialState() {
    return {
      chunk: null,
    };
  },

  componentWillReceiveProps(nextProps) {
    this.setState({chunk: null});
  },

  componentDidUpdate() {
    this.loadAsyncChunk();
  },

  componentDidMount() {
    this.loadAsyncChunk();
  },

  loadAsyncChunk() {
    if (this.props.loadChunk) {
      const loadChunk = this.getBottom(this.props.loadChunk);
      loadChunk.type(component => {
        if (component !== this.state.chunk) {
          this.setState({
            chunk: component,
          });
        }
      });
    }
  },

  getBottom(loadChunk) {
    if (loadChunk.props.loadChunk) {
      return this.getBottom(loadChunk.props.loadChunk);
    } else {
      return loadChunk;
    }
  },

  render() {
    let children;
    if (this.state.chunk) {
      const Chunk = this.state.chunk;
      children = (
        <Chunk 
          me={this.state.user} 
          {...this.props}
        />
      );
    } else {
      if (this.props.loadChunk) {
        children = <WaitAsyncChunk />;
      } else {
        children = this.props.children;
      }
    }
    
    return (
      <Navigation {...this.props} isLoggedIn={this.state.isLoggedIn} me={this.state.user}>
        {React.cloneElement(children, {
          me: this.state.user,
          fetchingUser: this.state.fetchingUser,
          ...this.props
        })}
      </Navigation>
    );
  }
});
```