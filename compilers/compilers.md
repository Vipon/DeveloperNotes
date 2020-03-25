# Компиляторы
## Clang
### Структура исходных файлов
Для того чтобы найти функцию __main__ компилятора __clang__ в исходниках, надо искать __add_clang_tool(clang__ в файлах cmake. Для версии __clang 8.0.0__ эта команда находится в __/clang/tools/driver/CMakeLists.txt__ и выглядит вот так:
```
add_clang_tool(clang
  driver.cpp
  cc1_main.cpp
  cc1as_main.cpp
  cc1gen_reproducer_main.cpp

  DEPENDS
  ${tablegen_deps}
  )
```
Соответсвенно, искать __main__ надо в одном из перечисленных файлов. Сейчас он находится в __driver.cpp__. Это функция, с которой начинает своё исполнение __clang__.

main:
| - TargetAndMode = ToolChain::getTargetAndModeFromProgramName(argv[0]); // Получает имя исполняемого файла.
| - std::unique_ptr<Compilation> C(TheDriver.BuildCompilation(argv)); // Создаёт обект компиляции из вектора аргументов.
|
|
|


### Классы и методы LLVM
Функция для инициализации. Лучше использовать перед работой с llvm инструментами.
```
class InitLLVM;
```
Инициализация всех потенциальных целей для компиляции --- процессорные архитектуры.
```
inline void InitializeAllTargets()
```


### __builtin Функции
Функции из <stdarg.h\> являются __builtin функциями в clang. Компилятором они реально встраиваются. 
```
 #ifndef _VA_LIST
 typedef __builtin_va_list va_list;
 #define _VA_LIST
 #endif
 #define va_start(ap, param) __builtin_va_start(ap, param)
 #define va_end(ap)          __builtin_va_end(ap)
 #define va_arg(ap, type)    __builtin_va_arg(ap, type)
```

 
### Внутренние типы данных
__SmallVector__ - вектор оптимизированный под работу с маленькими массивами.
```
template <typename T, unsigned N>
class SmallVector : public SmallVectorImpl<T>, SmallVectorStorage<T, N>;
```

### Сборка clang
* [build_clang.sh](./build_clang.sh) --- скрипт, который скачает все необходимые файлы, соберёт и протестирует clang/llvm.


### Flags
 * -dM --- генерирует список доступных макроопределений **#define **
 * -E --- прекратить компиляцию после этапа препроцессора.
 * -x --- спецификация языка программирования. Если ничего не указано, то тип языка определяется по расширению файла.
 * -mstackrealign --- force realign the stack at entry to every function (https://stackoverflow.com/questions/21631579/clang-produces-crashing-code-with-nostdlib)

#### Внутренние флаги Clang
* -cc1 --- флаг для работы только фронтенда Clang. Таким образом можно получить всё до создания объектника.
* -triple <value\> --- тройка/комбинация параметров, характерезующих платформу, для которой надо собирать код. 
	* <value\>: <arch\><sub\>-<vendor\>-<sys\>-<ab\>
		* Когда параметр не важен, можно использовать __unknown__.
		* arch = x86_64, i386, arm, thumb, mips, etc.
		* sub = for ex. on ARM: v5, v6m, v7a, v7m, etc.
		* vendor = pc, apple, nvidia, ibm, etc.
		* sys = none, linux, win32, darwin, cuda, etc.
		* abi = eabi, gnu, android, macho, elf, etc.
* -emit-obj --- результатом работы должен быть объекный файл для конкретной платформы.
-disable-free --- 
* -fmessage-length=N --- длина сообщений об ошибках.
-faddrsig --- генерация address-significance tables для оптимизаций линковщика (Safe ICF)


### Get list of predefined macrosses
```
clang -dM -E -x c /dev/null
```


# Program with clang
## Clang driver
```
#include "clang/Basic/Version.h"
#include "clang/Driver/Driver.h"
#include "clang/Driver/Options.h"
#include "clang/Driver/Compilation.h"
#include "clang/Frontend/CompilerInvocation.h"
#include "clang/Frontend/TextDiagnosticPrinter.h"
#include "clang/Basic/DiagnosticOptions.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/Host.h"
#include "llvm/Support/Program.h"
#include "llvm/ADT/ArrayRef.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/SmallString.h"
#include "llvm/ADT/IntrusiveRefCntPtr.h"
#include "llvm/Option/ArgList.h"
#include "llvm/Option/OptTable.h"
#include "llvm/Support/VirtualFileSystem.h"
#include "lld/Common/Driver.h"


std::string GetExecutablePath(const char *Argv0, bool CanonicalPrefixes)
{
  if (!CanonicalPrefixes) {
    clang::SmallString<128> ExecutablePath(Argv0);
    // Do a PATH lookup if Argv0 isn't a valid path.
    if (!llvm::sys::fs::exists(ExecutablePath))
      if (llvm::ErrorOr<std::string> P =
              llvm::sys::findProgramByName(ExecutablePath))
        ExecutablePath = *P;
    return ExecutablePath.str();
  }

  // This just needs to be some symbol in the binary; C++ doesn't
  // allow taking the address of ::main however.
  void *P = (void*) (intptr_t) GetExecutablePath;
  return llvm::sys::fs::getMainExecutable(Argv0, P);
}


// This lets us create the DiagnosticsEngine with a properly-filled-out
// DiagnosticOptions instance.
static clang::DiagnosticOptions *CreateAndPopulateDiagOpts(
    clang::ArrayRef<const char *> argv)
{
    auto *DiagOpts = new clang::DiagnosticOptions;
    std::unique_ptr<llvm::opt::OptTable> Opts(clang::driver::createDriverOptTable());
    unsigned MissingArgIndex, MissingArgCount;
    llvm::opt::InputArgList Args =
       Opts->ParseArgs(argv.slice(1), MissingArgIndex, MissingArgCount);
    // We ignore MissingArgCount and the return value of ParseDiagnosticArgs.
    // Any errors that would be diagnosed here will also be diagnosed later,
    // when the DiagnosticsEngine actually exists.
    (void)ParseDiagnosticArgs(*DiagOpts, Args);
    return DiagOpts;
}


int initDriver(const std::string& argv0, const std::vector<std::string>& gccFlags)
{
    clang::SmallVector<const char *, 256> argv(gccFlags.size() + 1);
    argv[0] = argv0.c_str();
    auto tempIt = argv.begin();
    ++tempIt;
    std::transform(gccFlags.begin(), gccFlags.end(), tempIt,
        [](const auto& arg) {
            return arg.c_str();
        }
    );

    bool CanonicalPrefixes = true; // depends on option "-no-canonical-prefixes"
    std::string targetTriple(getTriple(march));
    std::cout << targetTriple << std::endl;
    std::string Path = GetExecutablePath(argv[0], CanonicalPrefixes);

    clang::IntrusiveRefCntPtr<clang::DiagnosticOptions> DiagOpts =
        CreateAndPopulateDiagOpts(argv);
    clang::TextDiagnosticPrinter *DiagClient
        = new clang::TextDiagnosticPrinter(llvm::errs(), &*DiagOpts);
    clang::IntrusiveRefCntPtr<clang::DiagnosticIDs> DiagID(new clang::DiagnosticIDs());

    clang::DiagnosticsEngine Diags(DiagID, &*DiagOpts, DiagClient);

    clang::driver::Driver driver(Path, targetTriple, Diags);
    std::unique_ptr<clang::driver::Compilation> C(driver.BuildCompilation(argv));
    auto& hostToolChain = C->getDefaultToolChain(); 

    libPaths = hostToolChain.getFilePaths(); // standard library paths
    std::string installedDir = driver.getInstalledDir(); // directory of executable file 
}
```