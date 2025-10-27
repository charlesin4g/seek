package com.charles.seek.serviceImpl;

import com.charles.seek.dto.photo.request.AddUserPhotoRequest;
import com.charles.seek.dto.photo.response.UserPhotoItem;
import com.charles.seek.model.user.UserPhotoModel;
import com.charles.seek.repository.UserPhotoRepository;
import com.charles.seek.service.OssService;
import com.charles.seek.service.UserPhotoService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

/**
 * 用户照片服务实现
 *
 * 说明：
 * - 业务逻辑集中在服务层，包括实体与 DTO 转换、OSS URL 解析与签名；
 * - 控制器仅调用本服务方法，符合工作空间分层规范。
 */
@Service
@RequiredArgsConstructor
public class UserPhotoServiceImpl implements UserPhotoService {

    private final UserPhotoRepository photoRepository;
    private final OssService ossService;

    /** 将实体转换为响应 DTO（包含已解析的 URL） */
    private UserPhotoItem toItem(UserPhotoModel m) {
        UserPhotoItem item = new UserPhotoItem();
        item.setId(m.getId());
        item.setTitle(m.getTitle());
        item.setDescription(m.getDescription());
        item.setCreatedAt(m.getCreatedAt());
        // 使用后端统一的私有 URL 解析/签名逻辑
        item.setUrl(ossService.resolvePrivateUrl(m.getObjectKey(), null, null));
        return item;
    }

    @Override
    public UserPhotoItem addPhoto(AddUserPhotoRequest request) {
        UserPhotoModel model = new UserPhotoModel();
        model.setOwner(request.getOwner());
        model.setObjectKey(request.getObjectKey());
        model.setTitle(request.getTitle());
        model.setDescription(request.getDescription());
        UserPhotoModel saved = photoRepository.save(model);
        return toItem(saved);
    }

    @Override
    public List<UserPhotoItem> listByOwner(String owner) {
        return photoRepository.findByOwnerOrderByCreatedAtDesc(owner).stream()
                .map(this::toItem)
                .collect(Collectors.toList());
    }

    @Override
    public void deleteById(Long id) {
        photoRepository.deleteById(id);
    }
}