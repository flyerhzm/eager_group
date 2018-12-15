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
