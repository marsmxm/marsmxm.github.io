(self.webpackChunkborderless=self.webpackChunkborderless||[]).push([[334],{5194:function(e,t,n){"use strict";var a=n(18),l=n(3493),r=n.n(l),c=n(5007),s=n(5444);t.Z=function(e){var t=e.posts,n=(0,c.useState)(10),l=n[0],u=n[1],o=(0,c.useState)([]),i=o[0],m=o[1],d=(0,c.useMemo)((function(){return t.sort((function(e,t){var n=e.node.frontmatter,a=t.node.frontmatter,l=new Date(n.update.includes("0001")?n.date:n.update),r=new Date(a.update.includes("0001")?a.date:a.update);return l<r?1:l>r?-1:0})),t}),[t]),f=(0,c.useCallback)(r()((function(){window.outerHeight>document.querySelector(".post-list").getBoundingClientRect().bottom&&u((function(e){return e>=d.length?e:e+10}))}),250),[d]),p=(0,c.useCallback)((function(e){var t=e.map((function(e){var t=e.node,n=(t.excerpt,t.fields),a=t.frontmatter,l=n.slug,r=a.date,u=a.title,o=a.tags,i=a.update;1===Number(i.split(",")[1])&&(i=null);o.map((function(e){if("undefined"!==e)return c.createElement("div",{key:l+"-"+e,className:"tag"},c.createElement("span",null,c.createElement(s.Link,{to:"/tags#"+e},"#"+e)))}));return c.createElement("li",{key:l,className:"post"},c.createElement("article",null,c.createElement("h2",{className:"title"},c.createElement(s.Link,{to:l},u)),c.createElement("div",{className:"info"},c.createElement("div",{className:"date-wrap"},c.createElement("span",{className:"date"},r),i?c.createElement("span",{className:"update"}," ","(Updated: "+i+")"):null))))}));m((function(e){return[].concat((0,a.Z)(e),(0,a.Z)(t))}))}),[]);return(0,c.useEffect)((function(){l>0&&10!==l&&p(d.slice(i.length,l))}),[l]),(0,c.useEffect)((function(){return i.length&&m([]),u((function(e){return 10===e&&p(d.slice(0,10)),10})),window.addEventListener("scroll",f),function(){window.removeEventListener("scroll",f)}}),[d]),c.createElement("div",{className:"post-list"},c.createElement("ul",null,i))}},2287:function(e,t,n){"use strict";n.r(t);var a=n(5007),l=n(7606),r=n(8014),c=n(6098),s=n(7431),u=n(5194);t.default=function(e){var t=e.data.allMarkdownRemark.edges,n=(0,a.useState)(""),o=n[0],i=n[1],m=(0,a.useState)(!0),d=m[0],f=m[1],p=(0,a.useCallback)(t.filter((function(e){var t=e.node,n=t.frontmatter,a=t.rawMarkdownBody,l=n.title,r=o.toLocaleLowerCase();return!(d||!a.toLocaleLowerCase().includes(r))||l.toLocaleLowerCase().includes(r)})),[o,d]);return a.createElement(c.Z,null,a.createElement(s.Z,{title:"Search"}),a.createElement("div",{id:"Search"},a.createElement("div",{className:"search-inner-wrap"},a.createElement("div",{className:"input-wrap"},a.createElement(l.G,{icon:r.wn1}),a.createElement("input",{type:"text",name:"search",id:"searchInput",value:o,placeholder:"Search",autoComplete:"off",autoFocus:!0,onChange:function(e){i(e.currentTarget.value)}}),a.createElement("div",{className:"search-toggle"},a.createElement("span",{style:{opacity:d?.8:.15},onClick:function(){f(!0)}},"in Title"),a.createElement("span",{style:{opacity:d?.15:.8},onClick:function(){f(!1)}},"in Title+Content"))),""===o||p.length?null:a.createElement("span",{className:"no-result"},"No search results"),a.createElement(u.Z,{posts:""===o?t:p}))))}}}]);
//# sourceMappingURL=component---src-pages-search-tsx-1e11686c5d8a6e2c6bd2.js.map