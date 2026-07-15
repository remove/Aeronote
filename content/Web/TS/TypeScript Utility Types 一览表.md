---
publish: true
created: 2025-10-11T22:28:41.000+08:00
modified: 2026-07-15T13:01:58.591+08:00
---

<blockquote>
说明：这些是 TypeScript 内置的工具类型（Utility Types），用于在类型层面进行组合、筛选、映射和推导。
</blockquote>

<hr/>

<h2>一、属性修饰类</h2>

<table>
<thead>
<tr><th>名称</th><th>功能说明</th><th>示例</th></tr>
</thead>
<tbody>
<tr><td><code>Partial&lt;T&gt;</code></td><td>将所有属性变为可选</td><td><code>Partial&lt;{a:number,b:string}&gt;</code> → <code>{a?:number,b?:string}</code></td></tr>
<tr><td><code>Required&lt;T&gt;</code></td><td>将所有属性变为必填</td><td><code>Required&lt;{a?:number}&gt;</code> → <code>{a:number}</code></td></tr>
<tr><td><code>Readonly&lt;T&gt;</code></td><td>将所有属性变为只读</td><td><code>Readonly&lt;{a:number}&gt;</code> → <code>{readonly a:number}</code></td></tr>
<tr><td><code>Mutable&lt;T&gt;</code> <em>(自定义)</em></td><td>去掉只读修饰符</td><td><code>Mutable&lt;Readonly&lt;{a:number}&gt;&gt;</code> → <code>{a:number}</code></td></tr>
</tbody>
</table>

<hr/>

<h2>二、属性筛选类</h2>

<table>
<thead>
<tr><th>名称</th><th>功能说明</th><th>示例</th></tr>
</thead>
<tbody>
<tr><td><code>Pick&lt;T, K&gt;</code></td><td>从 <code>T</code> 中挑出键 <code>K</code></td><td><code>Pick&lt;{a:number,b:string}, 'a'&gt;</code> → <code>{a:number}</code></td></tr>
<tr><td><code>Omit&lt;T, K&gt;</code></td><td>从 <code>T</code> 中去掉键 <code>K</code></td><td><code>Omit&lt;{a:number,b:string}, 'a'&gt;</code> → <code>{b:string}</code></td></tr>
<tr><td><code>Record&lt;K, T&gt;</code></td><td>构造键为 <code>K</code>，值为 <code>T</code> 的对象</td><td><code>Record&lt;'a' &#124; 'b', number&gt;</code> → <code>{a:number,b:number}</code></td></tr>
</tbody>
</table>

<hr/>

<h2>三、类型提取 / 排除类</h2>

<table>
<thead>
<tr><th>名称</th><th>功能说明</th><th>示例</th></tr>
</thead>
<tbody>
<tr><td><code>Exclude&lt;T, U&gt;</code></td><td>从 <code>T</code> 中排除 <code>U</code></td><td><code>Exclude&lt;'a' &#124; 'b', 'b'&gt;</code> → <code>'a'</code></td></tr>
<tr><td><code>Extract&lt;T, U&gt;</code></td><td>从 <code>T</code> 中提取 <code>U</code></td><td><code>Extract&lt;'a' &#124; 'b', 'b'&gt;</code> → <code>'b'</code></td></tr>
<tr><td><code>NonNullable&lt;T&gt;</code></td><td>去除 <code>null</code> 和 <code>undefined</code></td><td><code>NonNullable&lt;string &#124; null &#124; undefined&gt;</code> → <code>string</code></td></tr>
</tbody>
</table>

<hr/>

<h2>四、函数相关类</h2>

<table>
<thead>
<tr><th>名称</th><th>功能说明</th><th>示例</th></tr>
</thead>
<tbody>
<tr><td><code>ReturnType&lt;F&gt;</code></td><td>获取函数返回类型</td><td><code>ReturnType&lt;() =&gt; string&gt;</code> → <code>string</code></td></tr>
<tr><td><code>Parameters&lt;F&gt;</code></td><td>获取函数参数类型（元组）</td><td><code>Parameters&lt;(x:number,y:string)=&gt;void&gt;</code> → <code>[number,string]</code></td></tr>
<tr><td><code>ConstructorParameters&lt;C&gt;</code></td><td>获取构造函数参数类型</td><td><code>ConstructorParameters&lt;typeof Date&gt;</code> → <code>[number]</code></td></tr>
<tr><td><code>InstanceType&lt;C&gt;</code></td><td>获取类的实例类型</td><td><code>InstanceType&lt;typeof Date&gt;</code> → <code>Date</code></td></tr>
</tbody>
</table>

<hr/>

<h2>五、Promise / 异步类</h2>

<table>
<thead>
<tr><th>名称</th><th>功能说明</th><th>示例</th></tr>
</thead>
<tbody>
<tr><td><code>Awaited&lt;T&gt;</code></td><td>拆解 <code>Promise</code> 的结果类型</td><td><code>Awaited&lt;Promise&lt;number&gt;&gt;</code> → <code>number</code></td></tr>
</tbody>
</table>

<hr/>

<h2>六、字符串操作类</h2>

<table>
<thead>
<tr><th>名称</th><th>功能说明</th><th>示例</th></tr>
</thead>
<tbody>
<tr><td><code>Uppercase&lt;S&gt;</code></td><td>将字符串字面量转为大写</td><td><code>Uppercase&lt;'abc'&gt;</code> → <code>'ABC'</code></td></tr>
<tr><td><code>Lowercase&lt;S&gt;</code></td><td>将字符串字面量转为小写</td><td><code>Lowercase&lt;'ABC'&gt;</code> → <code>'abc'</code></td></tr>
<tr><td><code>Capitalize&lt;S&gt;</code></td><td>首字母大写</td><td><code>Capitalize&lt;'hello'&gt;</code> → <code>'Hello'</code></td></tr>
<tr><td><code>Uncapitalize&lt;S&gt;</code></td><td>首字母小写</td><td><code>Uncapitalize&lt;'Hello'&gt;</code> → <code>'hello'</code></td></tr>
</tbody>
</table>

<hr/>

<h2>七、数组 / 对象进阶类</h2>

<table>
<thead>
<tr><th>名称</th><th>功能说明</th><th>示例</th></tr>
</thead>
<tbody>
<tr><td><code>ReadonlyArray&lt;T&gt;</code></td><td>只读数组类型</td><td><code>ReadonlyArray&lt;number&gt;</code> → <code>readonly number[]</code></td></tr>
<tr><td><code>PartialByKeys&lt;T, K&gt;</code> <em>(扩展)</em></td><td>指定属性可选</td><td><code>PartialByKeys&lt;{a,b,c}, 'a' &#124; 'c'&gt;</code></td></tr>
<tr><td><code>RequiredByKeys&lt;T, K&gt;</code> <em>(扩展)</em></td><td>指定属性必填</td><td><code>RequiredByKeys&lt;{a?,b?,c?}, 'a'&gt;</code></td></tr>
</tbody>
</table>

<hr/>

<h2>八、核心类型机制（这些是 Utility Types 的底层原理）</h2>

<table>
<thead>
<tr><th>机制</th><th>功能</th><th>示例</th></tr>
</thead>
<tbody>
<tr><td><code>keyof</code></td><td>获取对象的所有键名组成的联合类型</td><td><code>keyof {a:number,b:string}</code> → <code>'a' &#124; 'b'</code></td></tr>
<tr><td><code>in</code></td><td>在映射类型中遍历键</td><td><code>[K in keyof T]</code></td></tr>
<tr><td><code>extends</code></td><td>条件或约束判断</td><td><code>T extends U ? X : Y</code></td></tr>
<tr><td><code>infer</code></td><td>从类型中推断出另一类型</td><td><code>ReturnType</code>、<code>Awaited</code> 都使用了它</td></tr>
</tbody>
</table>

<hr/>

<h2>九、记忆建议</h2>

<ul>
<li>属性修饰类：<code>Partial</code> / <code>Required</code> / <code>Readonly</code></li>
<li>属性筛选类：<code>Pick</code> / <code>Omit</code> / <code>Record</code></li>
<li>函数类：<code>ReturnType</code> / <code>Parameters</code></li>
<li>联合类型操作类：<code>Exclude</code> / <code>Extract</code> / <code>NonNullable</code></li>
<li>Promise 类：<code>Awaited</code></li>
<li>字符串类：<code>Uppercase</code> / <code>Lowercase</code> / <code>Capitalize</code> / <code>Uncapitalize</code></li>
</ul>

<hr/>

<blockquote>
💡 提示：这些 Utility Types 只存在于 TypeScript 的编译阶段，<strong>不会影响运行时代码</strong>。<br/>
它们的作用是让 IDE 自动推导类型，提高类型安全性和智能提示质量。
</blockquote>
