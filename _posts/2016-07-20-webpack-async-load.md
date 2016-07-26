---
layout: post
title: ! '用Webpack实现React组件的异步加载'
categories:
- Web
tags: [React, React Router, Web Development, Webpack, Async, 异步]
status: publish
type: post
published: true
---

用JavaScript实现单页应用（SPA）的一个问题是，不做优化的情况下会生成一个巨大的JavaScript文件，第一次访问的用户需要很长时间来下载。如果前端使用[Webpack](https://webpack.github.io/)来实现代码集成，就可以通过它的[code splitting](http://webpack.github.io/docs/code-splitting.html)特性来实现代码分块，并按需异步加载代码块。

<br />
这篇文章针对的场景是结合React，React Router，Webpack实现的单页应用，目标是实现React Router的Route定义中对应组件的异步加载。达成这个目标的过程大致可以分为以下几步：

  1. 在Route configuration中用`getComponent`替换`component`，提供一个异步载入组件的接口。
  2. 通过Webpack的`require.ensure`实现组件的异步载入。
  3. 在最上级的父组件（最顶级Route对应的组件）中控制异步加载的流程。

<br />
以下为具体实现。

#### 第一步
根据React Router[文档](https://github.com/reactjs/react-router/blob/1.0.x/docs/API.md#getcomponentlocation-callback)，`getComponent`接受一个函数作为参数，这个函数的第二个参数`cb`是react-router提供的加载组件的接口。也就是说在第二步的具体实现中，只需将异步加载到的React组件传给函数`cb`即可。

```js
<Route path="courses/:courseId" getComponent={(location, cb) => {
  // 异步得到Course组建
  // ...

  cb(null, Course)
}}/>
```
<br />

#### 第二步
使用`require.ensure`实现异步加载。它的使用方法可参照下例：

```js
require.ensure(["module-a", "module-b"], function(require) {
    var a = require("module-a");
    // ...
});
```

但是本文中使用了[bundle-loader](https://github.com/webpack/bundle-loader)（它对`require.ensure`进行了封装）来将前两步的流程抽象化，而且可以更好的在第三步中控制加载过程。具体实现如下：

```js
const loadComponentAsync = loadChunk => (location, cb) => {
  cb(null, {loadChunk: loadChunk});
};

<Route 
  path="courses/:courseId" 
  getComponent={loadComponentAsync(require('bundle?lazy!./components/Course'))} 
/>
```

将`lazy`参数传给bundle-loader后，`require`不再会直接返回组件，而是返回一个函数，调用这个函数才会真正的开始下载JavaScript文件并加载组件，加载成功后会调用作为参数传递给它的回调函数：

```js
var load = require("bundle?lazy!./Component.js");

// 在调用load时开始加载文件
load(Component => {
  // 这里成功的加载到了组件
});
```

在上面第二步的实现中`loadComponentAsync`以`require`返回的函数`loadChunk`作为参数，返回一个`getComponent`需要的匿名函数。在这个匿名函数中用object的形式将`loadChunk`传给下一步中涉及到的顶级父组件来控制加载流程。

<br />

#### 第三步
父组件在Route配置中的位置大致如下：

```js
<Route component={App}>
  ...
  <Route 
    path="courses/:courseId" 
    getComponent={loadComponentAsync(require('bundle?lazy!./components/Course'))} 
  />
  ...
</Route>
```

App的相关实现如下：

```js
const App = React.createClass({
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
      children = <Chunk {...this.props} />;
    } else {
      if (this.props.loadChunk) {
        children = <WaitAsyncChunk />;
      } else {
        children = this.props.children;
      }
    }
    
    return (
      {React.cloneElement(children, {
        ...this.props
      })}
    );
  }
}

```

因为`loadChunk`是以object的形式传入（上一步中的`cb(null, {loadChunk: loadChunk})`），所以在父组件中是通过`this.props.loadChunk`来得到传入的加载函数（而不是通常的`this.props.children`）。在`loadAsyncChunk`中，通过`this.props.loadChunk`是否为`null`来判断当前子组件是否异步加载。`getBottom`是为了应对多级Route组件都是异步加载的情况，比如：

```js
<Route 
  path="courses" 
  getComponent={loadComponentAsync(require('bundle?lazy!./components/Courses'))} 
/>
  <Route 
    path="courses/:courseId" 
    getComponent={loadComponentAsync(require('bundle?lazy!./components/Course'))} 
  />
</Route>
```

在`render`中，如果`this.state.chunk`为空而`this.props.loadChunk`不为空，说明正在下载JavaScript文件，这时可以展示一个正在加载的UI元素，本例中的`<WaitAsyncChunk />`通过[NProgress](http://ricostacruz.com/nprogress/)在页面顶部展示一个进度条：

```js
const WaitAsyncChunk = React.createClass({

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

