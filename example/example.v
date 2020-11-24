module main

// git clone https://github.com/vebbling/vebbling
// ln -s $(pwd)/vebbling ~/.vmodules/vebbling  [or v build module ./vebbling]
// cd vebbling/example && v run example.v
// 
// curl http://127.0.0.1:8012

import vebbling
import json


struct User {
	name string
	age int
	sex bool
}

struct Book {
	name string
	author string
}


fn index(req vebbling.Request) vebbling.Response {
	return vebbling.response_redirect('/test6')
}

fn hello(req vebbling.Request) vebbling.Response {
	return vebbling.response_ok('hello world')
}

fn test1(req vebbling.Request) vebbling.Response {
	name := req.query['name']
	content := 'test1: name = $name'
	res := vebbling.response_text(content)
	return res
}

fn test2(req vebbling.Request) vebbling.Response {
	method := req.method
	if method == 'DELETE' {
		return vebbling.response_bad('can not delete data!')
	}
	name := req.get('name', 'jim')
	content := '$method: name = $name'
	mut res := vebbling.response_text(content)
	res.set_header('x-test-key', 'test-value')
	return res
}

fn test3(req vebbling.Request) vebbling.Response {
	name := req.get('name', 'lily')
	age := req.get('age', '18')
	sex_str := req.get('sex', '0')
	mut sex := true
	if sex_str in ['0', ''] {
		sex = false
	}
	user := User{name, age.int(), sex}
	res := vebbling.response_json(user)
	return res
}

fn test4(req vebbling.Request) vebbling.Response {
	res := vebbling.response_file('template/test4.html')
	return res
}

fn post_test4(req vebbling.Request) vebbling.Response {
	name := req.form['name']
	age := req.form['age']
	url := '/test3/?name=$name&age=$age'
	return vebbling.response_redirect(url)
}

fn test5(req vebbling.Request) vebbling.Response {
	return vebbling.response_file('template/test5.html')
}

fn test6(req vebbling.Request) vebbling.Response {
	mut view := vebbling.new_view(req, 'template/test6.html', 'element')
	if view.error != '' {
		return vebbling.response_bad(view.error)
	}
	if req.is_page() {
		println('a user is viewing the test6 page')
	} else {
		println('api request by vue')
		user := User{'lilei', 14, true}
		view.set('user', json.encode(user))
		users := [
			User{'Lucy', 13, false},
			User{'Lily', 13, false},
			User{'Jim', 12, true},
		]
		total_count := users.len + 1
		view.set('users', json.encode(users))
		view.set('total_count', json.encode(total_count))
	}
	return vebbling.response_view(view)
}


fn main() {

	mut app := vebbling.new_app(true)

	app.serve_static('/static/', './static/')

	app.route('/', index)  // as same as: ('', index)
	app.route('/hello/world', hello)
	app.route('/test1', test1)
	app.route('/test2', test2)
	app.route('/test3', test3)
	app.route('/test4', test4)
	app.route('POST:/test4', post_test4)
	app.route('/test5', test5)
	app.route('/test6', test6)
	
	// app.route('*', index)

	vebbling.runserver(app, 8012)

}

// http://127.0.0.1:8012
// http://127.0.0.1:8012/test1?name=hello
// http://127.0.0.1:8012/test2
// http://127.0.0.1:8012/test3
// http://127.0.0.1:8012/test4
// http://127.0.0.1:8012/test5
// http://127.0.0.1:8012/test6

