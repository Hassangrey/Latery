import 'package:fpdart/fpdart.dart';
import 'package:latery/src/core/failure.dart';

typedef FutureEither<T> = Future<Either<Failure, T>>;
typedef FutureVoid = FutureEither<void>;

// Type Future Either will take 1 type of data which is T
// Then it will take that T to put it in the fpdart object which is Either
// ? Either returnes 2 types of data, l(left) which is a failure
// And r{right) which is the success
// The failure is constant, so we should not repeat putting it everywhere in our app
// Thats why we defined this type, so we get the proprties of Either, while only passing 1 model instead of 2

// FutureVoid is the same, however it returns either a failure or nothing 
// Because sometimes we only need to make a simple operation (such as posting data which the user does while using the app).
