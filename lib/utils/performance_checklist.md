# Performance Optimization Quick Reference

## Quick Checklist for Developers

### When Creating Lists

✅ **DO:**
```dart
// Use ListView.builder for lazy loading
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    return ItemWidget(key: ValueKey(items[index].id), item: items[index]);
  },
)

// Use CustomScrollView with Slivers for complex layouts
CustomScrollView(
  slivers: [
    SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => ItemWidget(item: items[index]),
        childCount: items.length,
      ),
    ),
  ],
)
```

❌ **DON'T:**
```dart
// Avoid ListView with all children at once
ListView(
  children: items.map((item) => ItemWidget(item: item)).toList(),
)

// Avoid Column with many children
Column(
  children: items.map((item) => ItemWidget(item: item)).toList(),
)
```

### When Loading Images

✅ **DO:**
```dart
// Use OptimizedImage for network images
OptimizedImage(
  imageUrl: imageUrl,
  width: 200,
  height: 200,
  borderRadius: BorderRadius.circular(12),
)

// Use OptimizedAvatar for profile pictures
OptimizedAvatar(
  imageUrl: avatarUrl,
  radius: 40,
)
```

❌ **DON'T:**
```dart
// Avoid Image.network without caching
Image.network(imageUrl)

// Avoid loading full-size images for thumbnails
Image.network(imageUrl, width: 50, height: 50)
```

### When Building Widgets

✅ **DO:**
```dart
// Cache computed values
@override
Widget build(BuildContext context) {
  final statusColor = _getStatusColor();
  final formattedDate = _formatDate(date);
  final textStyle = AppTypography.h3.copyWith(color: statusColor);
  
  return Text(formattedDate, style: textStyle);
}

// Use const constructors
const SizedBox(height: 16)
const EdgeInsets.all(16)
const Icon(Icons.home)
```

❌ **DON'T:**
```dart
// Avoid computing in build method
@override
Widget build(BuildContext context) {
  return Text(
    _formatDate(date),
    style: AppTypography.h3.copyWith(color: _getStatusColor()),
  );
}

// Avoid non-const when const is possible
SizedBox(height: 16)
EdgeInsets.all(16)
```

### When Using State Management

✅ **DO:**
```dart
// Use Provider.select for specific updates
Consumer<ServiceProvider>(
  builder: (context, provider, child) {
    return Text('${provider.services.length} services');
  },
)

// Dispose controllers properly
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

❌ **DON'T:**
```dart
// Avoid rebuilding entire widget tree
Consumer<ServiceProvider>(
  builder: (context, provider, child) {
    return EntireScreen(provider: provider);
  },
)

// Avoid forgetting to dispose
@override
void dispose() {
  super.dispose();
  // Missing: _controller.dispose();
}
```

### When Implementing Pagination

✅ **DO:**
```dart
// Use LazyLoadingList for automatic pagination
LazyLoadingList<Service>(
  items: services,
  itemBuilder: (context, service, index) => ServiceCard(service: service),
  onLoadMore: () => provider.loadMoreServices(),
  hasMore: provider.hasMoreServices,
)

// Implement scroll listener for custom pagination
_scrollController.addListener(() {
  if (_scrollController.position.pixels >= 
      _scrollController.position.maxScrollExtent - 200) {
    _loadMore();
  }
});
```

❌ **DON'T:**
```dart
// Avoid loading all data at once
final allServices = await api.getAllServices(); // Could be thousands

// Avoid pagination without loading indicator
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) {
    if (index == items.length - 1) {
      loadMore(); // No loading indicator
    }
    return ItemWidget(item: items[index]);
  },
)
```

### Performance Monitoring

✅ **DO:**
```dart
// Log frame timing in debug mode
PerformanceUtils.logFrameTime('DashboardScreen');

// Measure expensive operations
await PerformanceUtils.measureBuildTime('LoadData', () async {
  await loadData();
});

// Use debounce for search
final debouncedSearch = PerformanceUtils.debounce(
  () => performSearch(query),
  delay: Duration(milliseconds: 300),
);
```

## Common Performance Patterns

### Pattern 1: Optimized List Item
```dart
class OptimizedListItem extends StatelessWidget {
  final Item item;
  
  const OptimizedListItem({
    super.key,
    required this.item,
  });
  
  @override
  Widget build(BuildContext context) {
    // Cache computed values
    final formattedDate = _formatDate(item.date);
    final statusColor = _getStatusColor(item.status);
    
    return Container(
      key: ValueKey(item.id), // Prevent unnecessary rebuilds
      child: Column(
        children: [
          Text(item.title),
          Text(formattedDate),
        ],
      ),
    );
  }
}
```

### Pattern 2: Lazy Loading with Pagination
```dart
class LazyListScreen extends StatefulWidget {
  @override
  State<LazyListScreen> createState() => _LazyListScreenState();
}

class _LazyListScreenState extends State<LazyListScreen> {
  final _scrollController = ScrollController();
  List<Item> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _page = 1;
  
  @override
  void initState() {
    super.initState();
    _loadItems();
    _scrollController.addListener(_onScroll);
  }
  
  void _onScroll() {
    if (_isLoading || !_hasMore) return;
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    
    if (maxScroll - currentScroll <= 200) {
      _loadItems();
    }
  }
  
  Future<void> _loadItems() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    final newItems = await api.getItems(page: _page, limit: 20);
    
    setState(() {
      _items.addAll(newItems);
      _page++;
      _hasMore = newItems.length >= 20;
      _isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _items.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _items.length) {
          return Center(child: CircularProgressIndicator());
        }
        return ItemWidget(key: ValueKey(_items[index].id), item: _items[index]);
      },
    );
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

### Pattern 3: Cached Network Image
```dart
class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final double size;
  
  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    this.size = 80,
  });
  
  @override
  Widget build(BuildContext context) {
    return OptimizedAvatar(
      imageUrl: imageUrl,
      radius: size / 2,
      placeholder: CircularProgressIndicator(),
      errorWidget: Icon(Icons.person),
    );
  }
}
```

## Performance Targets

- **App Startup:** < 3 seconds
- **Frame Rate:** 60 FPS (16ms per frame)
- **List Scroll:** Smooth, no jank
- **Image Load:** < 1 second with cache
- **API Response:** < 2 seconds
- **Memory Usage:** < 200MB typical

## Tools

1. **Flutter DevTools** - Profile performance
2. **Performance Overlay** - Show FPS in debug mode
3. **Timeline View** - Analyze frame rendering
4. **Memory Profiler** - Check for leaks

## Resources

- [Performance Best Practices](https://flutter.dev/docs/perf/best-practices)
- [Rendering Performance](https://flutter.dev/docs/perf/rendering-performance)
- [Performance Profiling](https://flutter.dev/docs/perf/ui-performance)
