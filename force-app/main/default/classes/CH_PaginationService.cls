/**
 * @author Rajesh Ediga
 * @description Bounded page sizes and keyset pagination helpers for ComponentHub.
 */
public with sharing class CH_PaginationService {
    public static final Integer DEFAULT_PAGE_SIZE = 20;
    public static final Integer MAX_PAGE_SIZE = 200;

    public static Integer normalizePageSize(Integer pageSize) {
        return CH_ValidationService.clampPageSize(pageSize, DEFAULT_PAGE_SIZE, MAX_PAGE_SIZE);
    }

    public static Boolean hasMore(Integer returnedSize, Integer pageSize) {
        Integer normalized = normalizePageSize(pageSize);
        return returnedSize != null && returnedSize >= normalized;
    }
}
