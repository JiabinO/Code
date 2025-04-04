# 为什么要挑选LiteOS作为改写对象？
## LiteOS当前状态：
### 工作量适合
LiteOS是华为开发的一个开源轻量级实时操作系统，面向物联网(IoT)领域。它的主要特点是体积小、资源占用少，适用于微控制器单元(MCU)和其他资源受限的嵌入式设备。
### 功能齐全
目前LiteOS开源项目支持ARM64、ARM Cortex-A、ARM Cortex-M0，Cortex-M3，Cortex-M4，Cortex-M7 等多种芯片架构。其内核架构包括不可裁剪的极小内核和可裁剪的其他模块。极小内核包含任务管理、内存管理、中断管理、异常管理和系统时钟。可裁剪的模块包括信号量、互斥锁、队列管理、事件管理、软件定时器等。
### 生态丰富
LiteOS还集成了一些网络协议栈，比如CoAP和MQTT，这使得它能够更容易地用于构建物联网应用。此外，LiteOS支持与Huawei LiteOS IoT SDK和HiLink平台的集成，这为开发者提供了丰富的开发资源和广泛的设备生态。

## LiteOS目前存在的局限性：
LiteOS作为一个轻量级的实时操作系统（RTOS），在设计上主要针对资源受限的嵌入式设备。尽管它在这些领域表现出色，但仍存在一些局限性，尤其在安全性、性能、可维护性和生态兼容性方面，我们小组主要考虑改进的是安全性。

在安全性方面，LiteOS也在持续进行改进，增加了一些安全特性来保护设备免受常见威胁。然而，由于其设计初衷是轻量化，并未专门为高安全需求的应用设计，因此它在安全机制上可能不如一些为安全性设计更为深入的操作系统，如细粒度的访问控制、安全启动、运行时防护等。并且由于其资源受限，LiteOS可能没有足够的资源来实施复杂的安全机制，如硬件加速的加密和解密功能。

# 为什么挑选Rust作为改写的语言？
## Rust语言的优势：
### 安全性
 Rust在安全性方面具有以下具体优势：
 
- 1. **所有权和借用检查**：
   Rust通过所有权（ownership）和借用（borrowing）规则强制执行内存安全，防止悬垂指针和数据竞争等问题。

- 2. **类型系统**：
   Rust的类型系统十分强大，它可以在编译时期捕获许多错误，包括无效的索引、类型不匹配和无效的引用等。

- 3. **无垃圾回收**：
   Rust不使用垃圾回收机制，因此避免了垃圾回收可能引起的延迟和复杂性，同时也减少了内存泄漏的风险。

- 4. **并发原语**：
   Rust提供了安全的并发原语，如互斥锁（Mutexes）、读写锁（RwLocks）、原子操作等，帮助开发者编写并发代码而不用担心数据竞争。

- 5. **生命周期**：
   Rust的生命周期（lifetimes）概念确保了引用的有效性，防止了悬垂引用的产生。

- 6. **抽象安全**：
   Rust允许开发者编写抽象代码而不必牺牲安全性，因为它的类型系统和所有权模型可以在编译时确保抽象的正确实现。

- 7. **错误处理**：
   Rust提供了一种表达性强的错误处理机制，要求显式地处理潜在的错误，避免了隐藏的错误和意外行为。

- 8. **标准库**：
   Rust的标准库经过精心设计，提供了一系列安全的数据结构和算法，减少了开发者自行实现时可能引入的安全漏洞。

- 9. **社区和生态**：
   Rust社区注重安全，经常进行代码审计，并在生态系统中提供了大量的安全工具和库。

- 10. **编译时检查**：
    Rust的编译器能够在代码编译时执行严格的检查，以确保遵守了语言的安全规则。

这些特性共同使得Rust成为一个在系统编程和嵌入式开发领域中备受推崇的安全语言选择。
### 性能
 Rust语言在改写LiteOS时，在性能方面的具体优势体现在以下几个方面：

- 1. **零开销抽象**：Rust的抽象不会引入运行时开销。它允许开发者直接操作硬件，同时提供了高级抽象，这意味着可以在保持性能的同时，编写出更安全、更易于维护的代码。

- 2. **优化的编译器**：Rust的编译器（例如LLVM）经过优化，能够生成高效的机器码。编译器会进行各种优化，比如内联函数、循环展开、向量化等，以提升执行效率。

- 3. **数据并行和并行计算**：Rust支持数据并行和并行计算，这可以充分利用多核处理器的能力，加快计算密集型任务的执行速度。

- 4. **无垃圾收集器**：Rust没有垃圾收集器（GC），这避免了GC可能带来的暂停和不确定的延迟。在实时操作系统中，这种确定性是非常重要的。

- 5. **控制流分析**：Rust的编译器能够进行复杂的控制流分析，优化代码路径，减少不必要的检查和跳转，从而提高执行速度。

- 6. **缓存友好的数据布局**：Rust允许开发者精确控制数据的内存布局，这有助于优化数据在缓存中的访问模式，减少缓存未命中。

- 7. **硬件接近性**：Rust提供了与硬件接近的编程接口，允许开发者编写高效的硬件操作代码，而不必通过高级抽象层。

- 8. **异步编程**：Rust的异步编程模型（通过`async`/`await`关键字）允许非阻塞IO操作，这可以在不牺牲多任务处理能力的情况下，提高IO密集型应用的性能。

综上所述，Rust在改写LiteOS时，能够提供高性能的运行时表现，这得益于其编译时优化、内存管理模型、以及对现代硬件特性的良好支持。

# 具体项目目标：
(TO BE DONE)

# 当前的市场需求：
在LiteOS的安全性方面，当前市场可能存在以下需求：

- 1. **增强的内存保护**：
市场需要能够防止恶意软件和程序错误导致的内存破坏的机制。

- 2. **更精细的访问控制**：
为了保护敏感数据和功能，需要实现基于角色的访问控制（RBAC）或类似机制。

- 3. **执行保护机制**：
需要实施代码和数据执行保护措施来防止恶意代码执行。

- 4. **漏洞管理和响应**：
市场需要有效的漏洞发现、评估、通知和修复流程。

- 5. **加密和认证支持**：
需要集成更强大的加密库，支持数据加密、安全认证和数字签名等功能。

- 6. **网络安全增强**：
市场需求包括防火墙、入侵检测系统和支持SSL/TLS的网络安全解决方案。

- 7. **安全启动**：
为了保证系统在启动过程中不被篡改，需要实现安全启动机制。

- 8. **限制调试和日志记录**：
需要对调试信息和日志记录进行限制，以减少潜在的安全风险。

- 9. **第三方组件的安全管理**：
市场需要确保所有依赖的第三方库和组件都是最新和最安全的版本。

- 10. **用户教育和文档**：
提供关于如何安全地使用和配置LiteOS的详细文档和用户培训。

- 11. **定制安全解决方案**：
对于特定行业或应用，可能需要定制化的安全解决方案来满足特殊的安全需求。

- 12. **合规性和标准遵从性**：
市场需求包括符合各种国际安全标准和法规，如ISO/IEC 27001、GDPR等。

随着物联网设备在各个行业的广泛应用，对LiteOS等轻量级操作系统的安全性要求越来越高，因此上述市场需求对于提升LiteOS的竞争力和市场份额至关重要。

# 可行性分析：
(TO BE DONE)

# 社区与生态支持：
- 1. **Rust语言本身的生态**：
Rust语言拥有一个活跃的社区和丰富的生态系统，提供了大量的库（crates），这些库可以用来处理网络、加密、串口通信、硬件抽象等在嵌入式系统中常见的功能。

- 2. **工具链**：
Rust提供了稳定的工具链，包括编译器、包管理器（Cargo）和各种调试工具，这些工具支持跨平台编译和部署，非常适合嵌入式开发

- 3. **cortex-m系列crate**：
对于基于ARM Cortex-M微控制器的系统，存在一系列专门的crate，比如cortex-m、cortex-m-rt和cortex-m-semihosting，它们提供了对Cortex-M核心的支持，包括上下文切换、中断处理等功能。

对应的github仓库网站：
```
https://github.com/rust-embedded/cortex-m
```
- 4. **官方资源**：
Rust语言的官方网站提供了大量的教程、文档和指南，帮助开发者学习如何使用Rust进行嵌入式开发。

对应官方网站：
```
https://www.rust-lang.org/
```

- 5. **论坛和社区**：
Rust社区活跃在多个论坛和社交媒体平台，如Reddit、Stack Overflow、Discord和IRC，开发者可以在这些平台上提问、分享经验和获取帮助。

- 6. **教育资源**：
存在很多在线课程、书籍和教程专注于Rust的嵌入式开发，例如“The Embedded Rust Book”和“Bare Metal Programming in Rust”。

# 预期成果：
(TO BE DONE)
