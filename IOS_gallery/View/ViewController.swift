import UIKit
import SDWebImage

class MainViewController: UIViewController {
    
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    private let viewModel = ImageGalleryViewModel()
    private var isSearching: Bool = false
    
    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)
    private let cellIdentifier = "ImageCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupSearchController()
        bindViewModel()
        setupPullToRefresh()
        
        // Initial load
        Task {
            await fetchImages()
        }
    }

    private func setupCollectionView() {
        imagesCollectionView.delegate = self
        imagesCollectionView.dataSource = self
        imagesCollectionView.isPagingEnabled = false
        let layout = PinterestLayout()
        layout.delegate = self
        imagesCollectionView.collectionViewLayout = layout

        let nib = UINib(nibName: cellIdentifier, bundle: nil)
        imagesCollectionView.register(nib, forCellWithReuseIdentifier: cellIdentifier)
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Images"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    private func bindViewModel() {
        viewModel.onDataFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.imagesCollectionView.reloadData()
                self?.refreshControl.endRefreshing()
            }
        }
    }

    private func setupPullToRefresh() {
        imagesCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }

    @objc private func refreshData() {
        Task {
            viewModel.resetSearch()
            await fetchImages()
        }
    }

    private func fetchImages() async {
        if viewModel.searchQuery.isEmpty {
            await viewModel.fetchImages()
        } else {
            await viewModel.searchImages(search: viewModel.searchQuery)
        }
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension MainViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ImageCell
        if let imageURLString = viewModel.images[indexPath.item].urls.small,
           let imageURL = URL(string: imageURLString) {
            cell.imageView.sd_setImage(with: imageURL)
        }
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height && !viewModel.isFetchingMore {
            Task {
                await fetchImages() // Fetch more images
            }
        }
    }
}

// MARK: - UISearchResultsUpdating
extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            isSearching = false
            return
        }
        viewModel.searchQuery = searchText
        Task {
            viewModel.resetSearch()
            await viewModel.searchImages(search: viewModel.searchQuery)
        }
    }
}

// MARK: - Pinterest Layout
extension MainViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForImageAtIndexPath indexPath: IndexPath) -> CGFloat {
        let totalHeight = collectionView.bounds.height - 90
        let numberOfRows: CGFloat = 4.0
        return totalHeight / numberOfRows
    }
}

// MARK: - UICollectionViewDelegateFlowLayout (optional)
extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width / 3, height: collectionView.frame.size.height / 150)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
