# frozen_string_literal: true

teacher1 = Teacher.create name: 'Teacher 1'
teacher2 = Teacher.create name: 'Teacher 2'
teacher3 = Teacher.create name: 'Teacher 3'
student1 = Student.create name: 'Student 1'
student2 = Student.create name: 'Student 2'
student3 = Student.create name: 'Student 3'
student4 = Student.create name: 'Student 4'
teacher1.students = [student1]
teacher2.students = [student2, student3, student4]

user1 = User.create(name: 'Alice')
user2 = User.create(name: 'Bob')

post1 = user1.posts.create(title: 'First post!')
post2 = user2.posts.create(title: 'Second post!')
post3 = user2.posts.create(title: 'Third post!')

post1.comments.create(status: 'created', rating: 4, author: student1)
post1.comments.create(status: 'approved', rating: 5, author: student1)
post1.comments.create(status: 'deleted', rating: 0, author: student2)

post2.comments.create(status: 'approved', rating: 3, author: student1)
post2.comments.create(status: 'approved', rating: 5, author: teacher1)

homework1 = Homework.create(student: student1, teacher: teacher1)
homework1 = Homework.create(student: student2, teacher: teacher1)

bus = SchoolBus.create(name: 'elementary bus')
sedan = Sedan.create(name: 'honda accord')

bus.passengers.create(name: 'Ruby', age: 7)
bus.passengers.create(name: 'Mike', age: 8)
bus.passengers.create(name: 'Zach', age: 9)
bus.passengers.create(name: 'Jacky', age: 10)

sedan.passengers.create(name: 'Ruby', age: 7)
sedan.passengers.create(name: 'Mike', age: 8)
sedan.passengers.create(name: 'Zach', age: 9)
sedan.passengers.create(name: 'Jacky', age: 10)
