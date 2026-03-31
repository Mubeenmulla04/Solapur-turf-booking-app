package com.solapur.turf.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.domain.Page;

import java.util.List;

/**
 * Standard pagination response wrapper.
 * Combines neatly with ApiResponse: ApiResponse.success(new
 * PageResponse<>(page.getContent(), ...), "Success");
 */
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class PageResponse<T> {
    private List<T> content;
    private int pageNumber;
    private int pageSize;
    private long totalElements;
    private int totalPages;
    private boolean isLast;

    public PageResponse(Page<T> page) {
        this.content = page.getContent();
        this.pageNumber = page.getNumber() + 1; // 1-indexed for the client
        this.pageSize = page.getSize();
        this.totalElements = page.getTotalElements();
        this.totalPages = page.getTotalPages();
        this.isLast = page.isLast();
    }
}
